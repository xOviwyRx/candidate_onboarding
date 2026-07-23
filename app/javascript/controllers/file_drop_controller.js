import { Controller } from "@hotwired/stimulus"

// §7.1's drag-and-drop upload field. The real file input stays in the form and
// keeps working on click — dropping just writes the file into it, so the server
// sees an ordinary upload either way.
export default class extends Controller {
  static targets = ["input", "zone", "filename"]
  static classes = ["active"]

  connect() {
    this.showFilename()
  }

  // Without preventDefault on both dragover and drop the browser takes over and
  // navigates to the dropped file, losing the page.
  over(event) {
    event.preventDefault()
    this.zoneTarget.classList.add(...this.activeClasses)
  }

  leave(event) {
    event.preventDefault()
    this.zoneTarget.classList.remove(...this.activeClasses)
  }

  drop(event) {
    event.preventDefault()
    this.leave(event)

    const [file] = event.dataTransfer.files
    if (!file) return

    // DataTransfer is the only way to set an input's files programmatically.
    const carrier = new DataTransfer()
    carrier.items.add(file)
    this.inputTarget.files = carrier.files

    this.showFilename()
  }

  // A styled drop zone otherwise gives no sign the drop landed: the native
  // input does not update its own label on a programmatic assignment.
  showFilename() {
    const [file] = this.inputTarget.files
    this.filenameTarget.textContent = file ? file.name : ""
  }
}
