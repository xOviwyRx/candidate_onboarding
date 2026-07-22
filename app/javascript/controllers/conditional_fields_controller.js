import { Controller } from "@hotwired/stimulus"

// Shows only the compensation fields that apply to the chosen job function and
// employment types. The model enforces the same rules; this is convenience.
export default class extends Controller {
  static targets = ["section", "jobFunction", "employmentType"]
  static values = { bigFunctions: Array, percentageTypes: Array }

  connect() {
    this.refresh()
  }

  refresh() {
    const jobFunction = this.jobFunctionTarget.value
    const employmentTypes = this.employmentTypeTargets.filter((box) => box.checked).map((box) => box.value)

    this.sectionTargets.forEach((section) => {
      section.hidden = !this.visible(section.dataset.showFor, jobFunction, employmentTypes)
    })
  }

  visible(rule, jobFunction, employmentTypes) {
    switch (rule) {
      case "salary":
        return employmentTypes.includes("employed")
      case "percentage":
        return employmentTypes.some((type) => this.percentageTypesValue.includes(type))
      case "big":
        return this.bigFunctionsValue.includes(jobFunction)
      default:
        return true
    }
  }
}
