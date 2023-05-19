namespace DSW1.Proyecto_Tienda_Zapatillas.Web.Models.Cliente
{
    public class Cliente
    {
        public int IdCliente { get; set; }
        public string Sexo { get; set; }
        public string Telefono { get; set; }
        public string Direccion { get; set; }

        //Llaves foraneas
        public int IdUsuarioCliente { get; set; }
        public int IdDistrito { get; set; }



        //Datos foreing UsuarioCliente
        public string Nombre { get; set; }
        public string ApePaterno { get; set; }
        public string ApeMaterno{ get; set; }
        public string Email { get; set; }

        //Datos foreing Distrito
        public string Distrito { get; set; }
        public string Provincia{ get; set; }

    }
}
