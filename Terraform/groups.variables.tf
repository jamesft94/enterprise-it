variable "department_groups" {
  description = "Map of departments and the HR attribute value that triggers membership"
  type = map(object({
    display_name = string
    description  = string
    hr_dept_name = string
  }))
  default = {
    rnd = {
      display_name = "SG-Dept-RnD-Engineering"
      description  = "R&D & Product Engineering - Grants GitHub, Azure Dev, and FreeIPA Linux access"
      hr_dept_name = "R&D"
    }
    care_ops = {
      display_name = "SG-Dept-Care-Operations"
      description  = "24/7 Care & Support Operations - Grants CRM, Support Desk, and Monitoring access"
      hr_dept_name = "Care Operations"
    }
    corporate = {
      display_name = "SG-Dept-Corporate-Business"
      description  = "Finance, HR, Sales & Admin - Grants ERP and Business Systems access"
      hr_dept_name = "Corporate"
    }
  }
}
