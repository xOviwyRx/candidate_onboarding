import { Controller } from "@hotwired/stimulus"

// Shows only the compensation fields that apply to the chosen job function and
// employment types. The model enforces the same rules; this is convenience.
export default class extends Controller {
  static targets = ["section", "jobFunction", "employmentType", "bigRegistrationStatus"]
  static values = { bigFunctions: Array, percentageTypes: Array }

  connect() {
    this.refresh()
  }

  refresh() {
    this.sectionTargets.forEach((section) => {
      section.hidden = !this.visible(section)
    })
  }

  visible(section) {
    switch (section.dataset.showFor) {
      case "salary":
        return this.employmentTypes.includes("employed")
      case "percentage":
        return this.employmentTypes.some((type) => this.percentageTypesValue.includes(type))
      case "big":
        return this.bigFunctionsValue.includes(this.jobFunctionTarget.value)
      // Nested inside the "big" section, so this only has to check the status.
      case "big_registered":
        return this.bigRegistrationStatusTarget.value === "registered"
      // §3.6: each skill carries the job functions it belongs to.
      case "skill":
        return section.dataset.jobFunctions.split(",").includes(this.jobFunctionTarget.value)
      default:
        return true
    }
  }

  get employmentTypes() {
    return this.employmentTypeTargets.filter((box) => box.checked).map((box) => box.value)
  }
}
