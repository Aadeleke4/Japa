import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="cart"
export default class extends Controller {
  // Initialize the controller and setup the cart display
  initialize() {
    console.log("Cart controller initialized");
    this.populateProvincesDropdown();
    this.loadCart();

    this.element.addEventListener("change", this.handleQuantityChange.bind(this));
  }

  handleQuantityChange(event) {
    if (event.target.classList.contains("quantity-input")) {
        const productId = parseInt(event.target.dataset.id);
        const newSize = event.target.dataset.size;
        const newQuantity = parseInt(event.target.value);

        console.log(`Changing product ${productId} to quantity ${newQuantity} for size ${newSize}`);
        this.updateCartItemQuantity(productId, newSize, newQuantity);
    }
}

updateCartItemQuantity(productId, newSize, newQuantity) {
  const cart = JSON.parse(localStorage.getItem("cart")) || [];
  const index = cart.findIndex(item => item.id === productId && item.size === newSize);

  if (index >= 0) {
      // Update the quantity of the item
      cart[index].quantity = newQuantity;

      // Update the local storage with the new cart state
      localStorage.setItem("cart", JSON.stringify(cart));

      // Update UI for this cart item
      this.updateCartItemDisplay(index, cart[index]);

      // Optionally, update the total display
      this.updateTotalDisplay(this.calculateTotal(cart));
  } else {
      console.error(`Item with ID ${productId} and size ${newSize} not found.`);
  }
}

updateCartItemDisplay(index, item) {
  const itemElement = document.querySelector(`#cart-item-${index}`); // Ensure you have a way to select the correct item
  if(itemElement) {
      itemElement.querySelector('.quantity-display').textContent = item.quantity;
      itemElement.querySelector('.total-price-display').textContent = (item.price * item.quantity).toFixed(2);
  }
}

calculateTotal(cart) {
  return cart.reduce((acc, item) => acc + (item.price * item.quantity), 0);
}

updateTotalDisplay(total) {
  const totalElement = document.getElementById('cart-total');
  if (totalElement) {
      totalElement.textContent = `Total: $${total.toFixed(2)}`;
  }
}






  populateProvincesDropdown() {
    const taxRates = {
      "British Columbia": { gst: 0.05, pst: 0.07 },
      "Saskatchewan": { gst: 0.05, pst: 0.06 },
      "Ontario": { gst: 0.05, pst: 0.00 },
      "Quebec": { gst: 0.05, pst: 0.09975 },
      "New Brunswick": { gst: 0.05, pst: 0.00 },
      "Nova Scotia": { gst: 0.05, pst: 0.00 },
      "Newfoundland and Labrador": { gst: 0.05, pst: 0.00 },
      "Prince Edward Island": { gst: 0.05, pst: 0.00 },
      "Yukon": { gst: 0.05, pst: 0.00 },
      "Northwest Territories": { gst: 0.05, pst: 0.00 },
      "Nunavut": { gst: 0.05, pst: 0.00 },
      "Manitoba":{ gst: 0.05, pst: 0.08 }
    };

    const provinceSelect = document.getElementById("province");
    Object.keys(taxRates).forEach(province => {
      let option = new Option(province, province);
      provinceSelect.add(option);
    });

    provinceSelect.addEventListener('change', () => {
      this.updateTotalDisplay(this.currentTotal);
    });
  }

  loadCart() {
    const cart = JSON.parse(localStorage.getItem("cart")) || [];
    if (cart.length === 0) {
      this.displayEmptyCart();
      return;
    }

    let total = 0;
    cart.forEach(item => {
      const itemTotal = item.price * item.quantity;
      total += itemTotal;
      this.displayCartItem({ ...item, total: itemTotal }); // Pass the total for each item for display
    });

    this.currentTotal = total; // Store total for reuse in dynamic updates
    this.updateTotalDisplay(total);
  }


  displayEmptyCart() {
    const invoiceContainer = document.getElementById("invoiceContainer");
    if (invoiceContainer) {
        invoiceContainer.innerText = "Your cart is empty.";
    } else {
        console.error("Invoice container not found.");
    }
}


  displayCartItem(item) {
    const div = document.createElement("div");
    div.classList.add("mt-2");
    div.innerHTML = `
        <span>Item: ${item.name} - $${(item.price / 100).toFixed(2)} - Size: ${item.size}</span>
        <input type="number" min="1" value="${item.quantity}" data-id="${item.id}" data-size="${item.size}" class="quantity-input">
    `;
    

    const deleteButton = this.createDeleteButton(item);
    div.appendChild(deleteButton);
    this.element.prepend(div);
  }

  createDeleteButton(item) {
    const deleteButton = document.createElement("button");
    deleteButton.innerText = "Remove";
    deleteButton.value = JSON.stringify({ id: item.id, size: item.size });
    deleteButton.classList.add("bg-gray-500", "rounded", "text-white", "px-2", "py-1", "ml-2");
    deleteButton.addEventListener("click", this.removeFromCart.bind(this));
    return deleteButton;
  }

  updateTotalDisplay(total) {
    const province = document.getElementById("province").value;
    this.updateTaxes(total, province);
  
    const totalEl = document.getElementById("total");
    totalEl.innerHTML = `<div>Total before taxes: $${(total / 100).toFixed(2)}</div>`;
    // This ensures only the total container's innerHTML is updated, not the whole cart container
  }

  updateTaxes(total, province) {
    // Define your tax rates here
    const taxRates = {
      "British Columbia": { gst: 0.05, pst: 0.07 },
      "Saskatchewan": { gst: 0.05, pst: 0.06 },
      "Ontario": { gst: 0.05, pst: 0.00 },
      "Quebec": { gst: 0.05, pst: 0.09975 },
      "New Brunswick": { gst: 0.05, pst: 0.00 },
      "Nova Scotia": { gst: 0.05, pst: 0.00 },
      "Newfoundland and Labrador": { gst: 0.05, pst: 0.00 },
      "Prince Edward Island": { gst: 0.05, pst: 0.00 },
      "Yukon": { gst: 0.05, pst: 0.00 },
      "Northwest Territories": { gst: 0.05, pst: 0.00 },
      "Nunavut": { gst: 0.05, pst: 0.00 }
      // Add more provinces with their rates
    };

    const rates = taxRates[province] || { gst: 0, pst: 0 };
    const gst = total * rates.gst;
    const pst = total * rates.pst;
    const totalWithTaxes = total + gst + pst;

    let taxContainer = document.getElementById("taxDetails");
    taxContainer.innerHTML = `
      GST ($${rates.gst * 100}%): $${(gst / 100).toFixed(2)}<br>
      PST ($${rates.pst * 100}%): $${(pst / 100).toFixed(2)}<br>
      Total with Taxes: $${(totalWithTaxes / 100).toFixed(2)}
    `;
  }

  clear() {
    localStorage.removeItem("cart");
    window.location.reload();
  }

  removeFromCart(event) {
    const cart = JSON.parse(localStorage.getItem("cart"));
    const values = JSON.parse(event.target.value);
    const index = cart.findIndex(item => item.id === values.id && item.size === values.size);
    if (index >= 0) {
      cart.splice(index, 1);
      localStorage.setItem("cart", JSON.stringify(cart));
      this.loadCart(); // Reload cart to update display
    }
  }
  
  checkout() {
    const cart = JSON.parse(localStorage.getItem("cart"));
    const province = document.getElementById("province").value;
    if (!cart || cart.length === 0 || !province) {
      alert("Your cart is empty or province is not specified!");
      return;
    }

    const payload = { cart: cart, province: province};
    const csrfToken = document.querySelector("[name='csrf-token']").content;

    fetch("/checkout", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken
      },
      body: JSON.stringify(payload)
    }).then(response => response.json())
      .then(data => {
        if (data.url) {
          window.location.href = data.url;
        } else {
          this.displayError(data.error || "An unknown error occurred.");
        }
      }).catch(error => {
        this.displayError("Network error. Please try again.");
      });
  }

  displayError(message) {
    const errorEl = document.createElement("div");
    errorEl.innerText = message;
    let errorContainer = document.getElementById("errorContainer");
    errorContainer.appendChild(errorEl);
  }
}
