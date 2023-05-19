using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using System.Text.Json;
using DSW1.Proyecto_Tienda_Zapatillas.Web.Models.Cliente;

namespace DSW1.Proyecto_Tienda_Zapatillas.Web.Controllers
{
    public class ClienteController : Controller
    {
        public readonly IConfiguration? _configuration;

        public ClienteController(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public IActionResult Index()
        {
            // Obtener el valor almacenado en la sesión
            string clienteJson = HttpContext.Session.GetString("cliente");

            if (clienteJson != null)
            {
                // Deserializar el JSON a un objeto de tipo Cliente
                Cliente cliente = JsonSerializer.Deserialize<Cliente>(clienteJson);

                // Utilizar los datos del cliente en tu lógica
                int IdCliente = cliente.IdCliente;

                ViewBag.ClienteId = IdCliente;

                // Por ejemplo, puedes acceder a las propiedades del cliente
                int idCliente = cliente.IdCliente;
                int idUsuarioCliente = cliente.IdUsuarioCliente;

                return View();
            }
            else
            {
                // La sesión no contiene los datos del cliente, maneja esta situación según tus necesidades
                return RedirectToAction("IniciarSesionUsuarioCliente", "Acceso");
            }
        }


    }
}
