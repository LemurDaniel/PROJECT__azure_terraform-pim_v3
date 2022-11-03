

##########################################################################
###################   	  Requests to PIM-API           ##################
##########################################################################

locals {

  # %s is placeholder for generated uuid for Update- and Remove-Request.
  pim_schedule_request_url_base = {
    eligible = "https://management.azure.com/%s/providers/Microsoft.Authorization/roleEligibilityScheduleRequests/%s?api-version=2020-10-01"
    active   = "https://management.azure.com/%s/providers/Microsoft.Authorization/roleAssignmentScheduleRequests/%s?api-version=2020-10-01"
  }


  # Base Request for Eligible and Active-Assignments
  # AdminUpdate for create
  # AdminRemove for remove
  base_schedule_request = {
    properties = {
      #condition        = "string"
      #conditionVersion = "string"
      requestType      = "%s_requestType_%s"
      justification    = "pim_${var.schedule_type}_assignment_created_on_${local.current_scope.type}_${local.current_scope.name}__by_ACF_deployment_code"
      principalId      = azuread_group.pim_assignment_ad_group.id
      roleDefinitionId = var.role_definition_id
      scheduleInfo = {
        expiration = {
          endDateTime = null
          duration    = local.is_assignment_permanent ? null : local.assignment_duration_encoded
          type        = local.is_assignment_permanent ? "NoExpiration" : "AfterDuration"
        }
        startDateTime = local.start_date_time
      }
      ticketInfo = {
        ticketNumber = ""
        ticketSystem = ""
      }
    }
  }

}


# Random uuids for schedule requests.

resource "random_uuid" "admin_update_request_uuid" {
  keepers = {
    admin_update_request = replace(jsonencode(local.base_schedule_request), "%s_requestType_%s", "AdminAssign")
    admin_remove_request = replace(jsonencode(local.base_schedule_request), "%s_requestType_%s", "AdminRemove")
  }

}
resource "random_uuid" "admin_remove_request_uuid" {
  keepers = {
    admin_update_request = replace(jsonencode(local.base_schedule_request), "%s_requestType_%s", "AdminAssign")
    admin_remove_request = replace(jsonencode(local.base_schedule_request), "%s_requestType_%s", "AdminRemove")
  }
}

resource "time_sleep" "wait_20_seconds" {

  triggers = {
    admin_update_request_uuid = random_uuid.admin_update_request_uuid.result
    admin_remove_request_uuid = random_uuid.admin_remove_request_uuid.result
  }

  create_duration = "20s"
}


# NUll Resource calling the PIM v3 ARM API
resource "null_resource" "pim_assignment_schedule_request" {
  depends_on = [time_sleep.wait_20_seconds]

  count = local.is_assignment_disabled ? 0 : 1

  triggers = {
    admin_update_request = replace(jsonencode(local.base_schedule_request), "%s_requestType_%s", "AdminAssign")
    admin_remove_request = replace(jsonencode(local.base_schedule_request), "%s_requestType_%s", "AdminRemove")

    admin_update_request_url = format(local.pim_schedule_request_url_base[var.schedule_type], local.current_scope.full, random_uuid.admin_update_request_uuid.result)
    admin_remove_request_url = format(local.pim_schedule_request_url_base[var.schedule_type], local.current_scope.full, random_uuid.admin_remove_request_uuid.result)

    # Invoking the (when testing) AdminRemove on Active-Assignments might result in two errors:
    # - Minimum Active Duration is 5 Minutes.
    # - Assignment not found.
  }



  provisioner "local-exec" {
    command = "az rest --method PUT --headers Content-type=application/json --url '${self.triggers.admin_update_request_url}' --body '${self.triggers.admin_update_request}'"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "az rest --method PUT --headers Content-type=application/json --url '${self.triggers.admin_remove_request_url}' --body '${self.triggers.admin_remove_request}'"
  }

}
