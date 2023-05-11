using Microsoft.AspNetCore.Mvc;

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
            return View();
        }


    }
}
