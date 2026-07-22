import { Controller } from "@hotwired/stimulus"

// Adds and removes rows in a fields_for section. Every row on this form is a new
// record, so removing one only has to take it off the page.
export default class extends Controller {
  static targets = ["rows", "template"]

  add(event) {
    event.preventDefault()

    const row = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, Date.now())
    this.rowsTarget.insertAdjacentHTML("beforeend", row)
  }

  remove(event) {
    event.preventDefault()
    event.target.closest("[data-nested-form-row]").remove()
  }
}
