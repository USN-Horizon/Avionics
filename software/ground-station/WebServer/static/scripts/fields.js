export function UpdateField(field_name, value) {
    const value_fields = document.querySelectorAll(".data-field");
    value_fields.forEach(field => {
        if (field.dataset.data_name == field_name) field.textContent = value;
    });
}