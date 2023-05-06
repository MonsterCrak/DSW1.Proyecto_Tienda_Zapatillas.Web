using Microsoft.AspNetCore.Mvc.ModelBinding;
using System.ComponentModel.DataAnnotations;

namespace DSW1.Proyecto_Tienda_Zapatillas.Web.Models.Acceso
{
    public class SesionColaborador
    {
        [EmailAddress(ErrorMessage = "Ingrese una dirección de correo electrónico válida")]
        [Required(ErrorMessage = "El campo Email es obligatorio")]
        public string Email { get; set; } = string.Empty;
        [DataType(DataType.Password)]
        [Required(ErrorMessage = "El campo Clave es obligatorio")]
        public string Clave { get; set; } = string.Empty;
        [BindNever]
        public string Mensaje { get; set; } = string.Empty;
    }
}
