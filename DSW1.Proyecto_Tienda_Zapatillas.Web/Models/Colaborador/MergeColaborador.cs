using DSW1.Proyecto_Tienda_Zapatillas.Web.Models.Colaborador.Select;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using System.ComponentModel.DataAnnotations;

namespace DSW1.Proyecto_Tienda_Zapatillas.Web.Models.Colaborador
{
    public class MergeColaborador
    {
        [Required(ErrorMessage = "El DNI es obligatorio.")]
        [RegularExpression(@"^\d{8}$", ErrorMessage = "El DNI debe tener 8 dígitos.")]
        public string DNI { get; set; }

        [Required(ErrorMessage = "El nombre es obligatorio.")]
        [StringLength(50, ErrorMessage = "El nombre no puede tener más de 50 caracteres.")]
        public string Nombre { get; set; }

        [Required(ErrorMessage = "El apellido paterno es obligatorio.")]
        [StringLength(50, ErrorMessage = "El apellido paterno no puede tener más de 50 caracteres.")]
        public string ApePaterno { get; set; }

        [Required(ErrorMessage = "El apellido materno es obligatorio.")]
        [StringLength(50, ErrorMessage = "El apellido materno no puede tener más de 50 caracteres.")]
        public string ApeMaterno { get; set; }

        [Required(ErrorMessage = "El sexo es obligatorio.")]
        [StringLength(10, ErrorMessage = "El sexo no puede tener más de 10 caracteres.")]
        public string Sexo { get; set; }

        [Required(ErrorMessage = "El sueldo es obligatorio.")]
        [RegularExpression(@"^\d+(\.\d{1,2})?$", ErrorMessage = "El sueldo debe tener un formato decimal válido.")]
        public double Sueldo { get; set; }

        [Required(ErrorMessage = "El teléfono es obligatorio.")]
        [StringLength(15, ErrorMessage = "El teléfono no puede tener más de 15 caracteres.")]
        public string Telefono { get; set; }

        [Required(ErrorMessage = "La dirección es obligatoria.")]
        [StringLength(100, ErrorMessage = "La dirección no puede tener más de 100 caracteres.")]
        public string Direccion { get; set; }

        [Required(ErrorMessage = "Seleccione un Cargo")]
        public string IdCargo { get; set; }

        [Required(ErrorMessage = "Seleccione un estado")]
        public string IdEstado { get; set; }

        [Required(ErrorMessage = "Seleccione un distrito")]
        public string IdDistrito { get; set; }

        [BindNever]
        public string Mensaje { get; set; } = string.Empty;


        // Extra

        [Required(ErrorMessage = "Selecciona una provincia")]
        public int IdProvincia { get; set; }

        [Required(ErrorMessage = "Selecciona una provincia")]
        public List<Provincia> Provincias { get; set; }

        [Required(ErrorMessage = "Selecciona una provincia")]
        public List<Cargo> Cargos { get; set; }

        [Required(ErrorMessage = "Selecciona una provincia")]
        public List<Estado> Estados { get; set; }
    }

}
