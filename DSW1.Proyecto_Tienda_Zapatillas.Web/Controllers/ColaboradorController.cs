using DSW1.Proyecto_Tienda_Zapatillas.Web.Models.Acceso;
using DSW1.Proyecto_Tienda_Zapatillas.Web.Models.Colaborador;
using DSW1.Proyecto_Tienda_Zapatillas.Web.Models.Colaborador.Select;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.Data.SqlClient;
using Newtonsoft.Json;
using System.Data;

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


        //----------
        public int SelectProvincias()
        {
            List<Provincia> provincias = new List<Provincia>();
            int idProvincia = 0;
            using (SqlConnection connection = new SqlConnection(_configuration.GetConnectionString("cnDB")))
            {
                using (SqlCommand command = new SqlCommand("SelectProvincias", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    connection.Open();

                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            Provincia p = new Provincia();
                            p.IdProvincia = Convert.ToInt32(reader["IdProvincia"]);
                            p.Descripcion = reader["Descripcion"].ToString();

                            provincias.Add(p);
                        }

                        if (provincias.Count > 0)
                        {
                            ViewBag.Provincias = new SelectList(provincias, "IdProvincia", "Descripcion");
                            idProvincia = provincias.First().IdProvincia;
                        }
                    }
                }
            }

            return idProvincia;
        }

        public JsonResult GetDistritosByProvincia(int idProvincia)
        {
            List<Distrito> distritos = new List<Distrito>();
            using (SqlConnection connection = new SqlConnection(_configuration.GetConnectionString("cnDB")))
            {
                using (SqlCommand command = new SqlCommand("GetDistritosByProvincia", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@IdProvincia", idProvincia);
                    connection.Open();
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            Distrito d = new Distrito();
                            d.IdDistrito = Convert.ToInt32(reader["IdDistrito"]);
                            d.Descripcion = reader["Descripcion"].ToString();
                            d.IdProvincia = Convert.ToInt32(reader["IdProvincia"]);
                            distritos.Add(d);
                        }
                    }
                }
            }
            return Json(distritos);
        }


        public IActionResult MergeColaborador()
        {
            int idProvincia = SelectProvincias(); // Obtener el id de provincia
            

            var provincias = ViewBag.Provincias;

            

            return View();
        }


        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult MergeColaborador(MergeColaborador colaborador)
        {
            string mensaje = string.Empty;
            
            try
            {
                using (SqlConnection connection = new SqlConnection(_configuration.GetConnectionString("cnDB")))
                {
                    using (SqlCommand command = new SqlCommand("sp_mergeColaborador", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        command.Parameters.AddWithValue("@DNI", colaborador.DNI);
                        command.Parameters.AddWithValue("@Nombre", colaborador.Nombre);
                        command.Parameters.AddWithValue("@ApePaterno", colaborador.ApePaterno);
                        command.Parameters.AddWithValue("@ApeMaterno", colaborador.ApeMaterno);
                        command.Parameters.AddWithValue("@Sexo", colaborador.Sexo);
                        command.Parameters.AddWithValue("@Sueldo", colaborador.Sueldo);
                        command.Parameters.AddWithValue("@Telefono", colaborador.Telefono);
                        command.Parameters.AddWithValue("@Direccion", colaborador.Direccion);
                        command.Parameters.AddWithValue("@IdCargo", colaborador.IdCargo);
                        command.Parameters.AddWithValue("@IdEstado", colaborador.IdEstado);
                        command.Parameters.AddWithValue("@IdDistrito", colaborador.IdDistrito);

                        SqlParameter mensajeParam = new SqlParameter("@Mensaje", SqlDbType.VarChar, 100);
                        mensajeParam.Direction = ParameterDirection.Output;
                        command.Parameters.Add(mensajeParam);

                        connection.Open();
                        command.ExecuteNonQuery();

                        mensaje = mensajeParam.Value.ToString();
                    }
                }
            }
            catch (Exception ex)
            {
                mensaje = "Error en la ejecución del procedimiento almacenado: " + ex.Message;
            }

            ViewBag.Mensaje = mensaje;

            int idProvincia = SelectProvincias(); // Obtener el id de provincia


            var provincias = ViewBag.Provincias;


            return View(colaborador);
        }




    }
}
