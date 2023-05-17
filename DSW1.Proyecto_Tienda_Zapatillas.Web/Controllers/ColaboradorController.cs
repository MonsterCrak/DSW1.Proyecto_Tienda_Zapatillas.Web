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

        private List<Provincia> ObtenerProvincias()
        {
            List<Provincia> provincias = new List<Provincia>();

            try
            {
                using (SqlConnection connection = new SqlConnection(_configuration.GetConnectionString("cnDB")))
                {
                    using (SqlCommand command = new SqlCommand("SELECT IdProvincia, Descripcion FROM Provincia", connection))
                    {
                        connection.Open();

                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                Provincia provincia = new Provincia();
                                provincia.IdProvincia = Convert.ToInt32(reader["IdProvincia"]);
                                provincia.Descripcion = reader["Descripcion"].ToString();
                                provincias.Add(provincia);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ViewBag.Mensaje = "Error en busqueda de provincias";
            }

            return provincias;
        }

        private List<Cargo> ObtenerCargo()
        {
            List<Cargo> cargos = new List<Cargo>();

            try
            {
                using (SqlConnection connection = new SqlConnection(_configuration.GetConnectionString("cnDB")))
                {
                    using (SqlCommand command = new SqlCommand("SELECT IdCargo, Descripcion FROM Cargo;", connection))
                    {
                        connection.Open();

                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                Cargo cargo = new Cargo();
                                cargo.IdCargo = Convert.ToInt32(reader["IdCargo"]);
                                cargo.Descripcion = reader["Descripcion"].ToString();
                                cargos.Add(cargo);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ViewBag.Mensaje = "Error en busqueda de cargos";
            }

            return cargos;
        }

        private List<Estado> ObtenerEstado()
        {
            List<Estado> estados = new List<Estado>();

            try
            {
                using (SqlConnection connection = new SqlConnection(_configuration.GetConnectionString("cnDB")))
                {
                    using (SqlCommand command = new SqlCommand("SELECT IdEstado, Descripcion FROM Estado;", connection))
                    {
                        connection.Open();

                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                Estado estado = new Estado();
                                estado.IdEstado = Convert.ToInt32(reader["IdEstado"]);
                                estado.Descripcion = reader["Descripcion"].ToString();
                                estados.Add(estado);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ViewBag.Mensaje = "Error en busqueda de Estados";
            }

            return estados;
        }


        public IActionResult GetDistritosByProvincia(int idProvincia)
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
                            Distrito distrito = new Distrito();
                            distrito.IdDistrito = Convert.ToInt32(reader["IdDistrito"]);
                            distrito.Descripcion = reader["Descripcion"].ToString();
                            distritos.Add(distrito);
                        }
                    }
                }
            }

            return Json(distritos);
        }



        public IActionResult MergeColaborador()
        {
            var colaborador = new MergeColaborador();
            colaborador.Provincias = ObtenerProvincias(); // Inicializa la propiedad Provincias con una lista de provincias
            colaborador.Cargos = ObtenerCargo();
            colaborador.Estados = ObtenerEstado();


            return View(colaborador);
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
            colaborador.Provincias = ObtenerProvincias();
            colaborador.Cargos = ObtenerCargo();
            colaborador.Estados = ObtenerEstado();
            ModelState.Clear();

            return View(colaborador);
        }



    }
}
