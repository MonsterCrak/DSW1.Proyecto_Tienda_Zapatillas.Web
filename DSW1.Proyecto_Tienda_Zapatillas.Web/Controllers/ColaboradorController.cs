using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DSW1.Proyecto_Tienda_Zapatillas.Web.Controllers
{
    [Authorize]
    public class ColaboradorController : Controller
    {
        public readonly IConfiguration? _configuration;

        public ColaboradorController(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public IActionResult Index()
        {
            return View();
        }
    }
}
