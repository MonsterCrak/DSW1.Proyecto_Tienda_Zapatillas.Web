using Microsoft.AspNetCore.Mvc.ModelBinding;
using System.ComponentModel.DataAnnotations;

namespace DSW1.Proyecto_Tienda_Zapatillas.Web.Models.Acceso
{
    public class RegistroColaborador
    {
        [Required(ErrorMessage = "El Campo Email obligatorio")]
        [EmailAddress(ErrorMessage = "Ingrese una dirección de correo electrónico válida")]
        public string Email { get; set; } = string.Empty;

        [DataType(DataType.Password)]
        [Required(ErrorMessage = "El Campo Contraseña obligatorio")]
        public string Clave { get; set; } = string.Empty;

        [Required(ErrorMessage = "El Campo DNI obligatorio")]
        [RegularExpression(@"^\d{8}$", ErrorMessage = "Ingrese un DNI válido")]
        public string DNI { get; set; } = string.Empty;

        [BindNever]
        public string Mensaje { get; set; } = string.Empty;
    }
}
