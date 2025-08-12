class NaNumberToggles {
  constructor() {
    this.processedCheckboxes = new WeakSet();
  }

  init() {
    this.attachListeners();
  }

  attachListeners() {
    const naCheckboxes = document.querySelectorAll('.na-label input[type="checkbox"]');
    naCheckboxes.forEach((checkbox) => this.setupCheckbox(checkbox));
  }

  setupCheckbox(checkbox) {
    if (this.processedCheckboxes.has(checkbox)) return;
    this.processedCheckboxes.add(checkbox);

    this.updateNumberFieldState(checkbox);

    checkbox.addEventListener("change", () => this.updateNumberFieldState(checkbox));
  }

  updateNumberFieldState(checkbox) {
    const label = checkbox.parentElement;
    const numberInput = label.previousElementSibling;
    
    if (!numberInput || !numberInput.classList.contains('number')) {
      console.warn('Could not find number input for N/A checkbox', checkbox);
      return;
    }

    if (checkbox.checked) {
      if (numberInput.value !== '0' && numberInput.value !== '') {
        checkbox.dataset.previousValue = numberInput.value;
      }
      numberInput.disabled = true;
      numberInput.value = '0';
    } else {
      numberInput.disabled = false;
      if (checkbox.dataset.previousValue) {
        numberInput.value = checkbox.dataset.previousValue;
        delete checkbox.dataset.previousValue;
      }
    }
  }

  cleanup() {
    this.attachListeners();
  }
}

const naNumberToggles = new NaNumberToggles();

document.addEventListener("DOMContentLoaded", () => naNumberToggles.init());

document.addEventListener("turbo:load", () => {
  naNumberToggles.cleanup();
  naNumberToggles.init();
});

document.addEventListener("turbo:frame-load", () => {
  naNumberToggles.attachListeners();
});