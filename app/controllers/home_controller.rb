class HomeController < ApplicationController
  def index
  end
  def find
    # Recibo los parametros
    id = params[:id]
    start = Date.parse(params[:start])
    finish = Date.parse(params[:finish])
    @last_day_of_query = finish.yday
    # Instancio dos variables que me definira el punto inicial y final de la funcion consultar()
    @recursive_start = start.yday
    @recursive_end = @last_day_of_query
    # Realizo estas variables en 0, estaran operando entre si
    @facturas = 0
    @llamadas = 0
    consultar(id, start, finish)
    @respuesta = {
      :facturas => @facturas,
      :llamadas => @llamadas
    }
    puts "Resultado final [facturas: #{@facturas}] [llamadas: #{@llamadas}]"
    # Y por ultimo creo una respuesta en formato json :)
    respond_to do |format|
      format.json { render :find, status: :ok, location: @respuesta.to_json }
    end
  end
  def consultar(id, s, f)
    # Creo mi contador de las veces que llama esta funcion (request)
    @llamadas = @llamadas + 1
    # Me creo un log en la consulta de rails para ir mirando el progreso
    puts "\n Consultado las fechas #{s.strftime('%F')} - #{f.strftime('%F')}"
    puts "Numero de facturas consultadas: #{@facturas} "
    puts "Numero de llamadas: #{@llamadas} "
    # Realizo el request
    consulta_facturas = HTTP.get("http://34.209.24.195/facturas", :params => {
        :id => id,
        :start => s.strftime("%F"),
        :finish => f.strftime("%F")
      }
    ).to_s
    # Si el resultado es que encontro mas de 100 registros entra a este if
    if consulta_facturas.mb_chars.length == 27
      # Creo unas variables en esta funcion recursiva que me controla un punto de inicio y final
      # entonces cuando cumple debo acortar a la mitad el punto final y volver a iterarlo
      @recursive_end = (@recursive_start + @recursive_end) / 2
      # Con esta funcion de rails puedo saber que dia es, avanzando n dias
      # por ejemplo que dia el numero 92 del 2017 = 2017-04-02 00:00:00 -0500
      # y debo restar 1 por que inicia a partir del dia 0

      num_to_fechas = {
        s: Time.new(s.year).advance(days: @recursive_start-1),
        f: Time.new(s.year).advance(days: @recursive_end-1)
      }
      # Me vuelvo a llamar ya con un rango menor
      consultar(id, num_to_fechas[:s], num_to_fechas[:f])
    else
      # Almaceno en @facturas la respuesta del request y lo casteno en int
      @facturas = @facturas + consulta_facturas.to_i
      # La unica  manera para detener esta recursividad, es que el punto final sea igual al ultimo dia del año (365 en este caso)
      # si no, entra en este if, donde declaro que el punto inicial ahora sera el ultimo punto encontrado por el punto final
      if @recursive_end != @last_day_of_query
        @recursive_start = @recursive_end + 1
        @recursive_end = @last_day_of_query
        num_to_fechas = {
          s: Time.new(s.year).advance(days: @recursive_start-1),
          f: Time.new(s.year).advance(days: @recursive_end-1)
        }
        consultar(id, num_to_fechas[:s], num_to_fechas[:f])
      end
    end
  end
end
