using Microsoft.AspNetCore.Mvc.ModelBinding;
using System.ComponentModel.DataAnnotations;

namespace DSW1.Proyecto_Tienda_Zapatillas.Web.Models.Acceso
{
    public class RegistroCliente
    {
        [Required(ErrorMessage = "El Campo Nombre obligatorio")]
        public string Nombre { get; set; } = string.Empty;

        [Required(ErrorMessage = "El Campo Paterno obligatorio")]
        public string ApePaterno { get; set; } = string.Empty;

        [Required(ErrorMessage = "El Campo Materno obligatorio")]
        public string ApeMaterno { get; set; } = string.Empty;

        [EmailAddress(ErrorMessage = "Ingrese una dirección de correo electrónico válida")]
        [Required(ErrorMessage = "El Campo Email obligatorio")]
        public string Email { get; set; } = string.Empty;

        [DataType(DataType.Password)]
        [Required(ErrorMessage = "El Campo Contraseña obligatorio")]
        public string Clave { get; set; } = string.Empty;

        [BindNever]
        public int? IdTipoUsuario { get; set; } = 1;

        [BindNever]
        public string Mensaje { get; set; } = string.Empty;

    }
}
