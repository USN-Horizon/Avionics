export function UpdateField(field_name, value) {
    const value_fields = document.querySelectorAll(".field-" + field_name);
    value_fields.forEach(field => {
        field.textContent = value;
    });
}