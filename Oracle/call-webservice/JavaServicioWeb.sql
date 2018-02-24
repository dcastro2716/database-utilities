import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.sql.Clob;
import java.sql.SQLException;

public class JavaServicioWeb {
	public static Clob call_ws(String endpoint, Clob xmlClob, Clob respuesta) {
		if (respuesta == null)
			throw new IllegalArgumentException("Error JavaServicioWeb: Clob no puede ser null");
		if (endpoint == null)
			throw new IllegalArgumentException("Error JavaServicioWeb: El endpoint no puede ser null");
		if (xmlClob == null)
			throw new IllegalArgumentException("Error JavaServicioWeb: El mensaje xml no puede ser null");

		String xml=readClob(xmlClob);
		StringBuffer xmlStr = new StringBuffer();
		String strLinea = "";
		String Smensaje = "";
		URL url = null;
		HttpURLConnection urlc = null;
		DataOutputStream salida = null;
		BufferedReader entrada = null;
		boolean fullEnvelop=false;
		
		try {
			try {
				url = new URL(endpoint);
			} catch (MalformedURLException e) {
				throw new RuntimeException(
						"Error JavaServicioWeb: La URL del endpoint es invalida: " + endpoint + " " + e.getMessage());
			}

			try {
				urlc = (HttpURLConnection) url.openConnection();
			} catch (IOException e) {
				throw new RuntimeException("Error JavaServicioWeb: No se puede conectar con el endpoint: " + endpoint
						+ " " + e.getMessage());
			}
			urlc.setDoOutput(true);

			urlc.setRequestProperty("Accept", "application/soap+xml, application/dime, multipart/related, text/*");
			urlc.setRequestProperty("Content-Type", "text/xml");
			urlc.setRequestProperty("Host", url.getHost());

			urlc.setRequestProperty("SOAPAction", "\"process\"");
			
			if(xml.startsWith("<soapenv:Envelope")){
				Smensaje = "<?xml version=\"1.0\" encoding=\"iso-8859-1\" ?> "+xml;
				fullEnvelop=true;
			}else{
				Smensaje = "<?xml version=\"1.0\" encoding=\"iso-8859-1\" ?> <soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"><soapenv:Body>"
						+ xml + "</soapenv:Body></soapenv:Envelope>";
			}
			urlc.setRequestProperty("Content-Length", "" + Smensaje.length());

			try {
				salida = new DataOutputStream(urlc.getOutputStream());
			} catch (IOException e) {
				throw new RuntimeException("Error JavaServicioWeb: No se pudo abrir comunicacion con el endpoint: "
						+ endpoint + " " + e.getMessage());
			}
			try {
				salida.writeBytes(Smensaje + "\r\n\r\n");
			} catch (IOException e) {
				throw new RuntimeException("Error JavaServicioWeb: No se pudo enviar el mensaje al endpoint: "
						+ endpoint + " " + e.getMessage());
			}
			try {
				salida.close();
			} catch (IOException e) {
				System.out.println(e.getMessage());
			}

			urlc.disconnect();

			try {
				entrada = new BufferedReader(new InputStreamReader(urlc.getInputStream()));
			} catch (IOException e) {
				throw new RuntimeException("Error JavaServicioWeb: No se pudo obtener la respuesta del servicio: "
						+ endpoint + " " + e.getMessage());
			}

			try {
				while ((strLinea = entrada.readLine()) != null)
					xmlStr.append(strLinea);
			} catch (IOException e) {
				throw new RuntimeException("Error JavaServicioWeb: No se pudo leer la respuesta del servicio: "
						+ endpoint + " " + e.getMessage());
			}

			try {
				entrada.close();
			} catch (IOException e) {
				System.out.println(e.getMessage());
			}

			String xmlFinal = null;
			if(fullEnvelop){
				xmlFinal = xmlStr.toString();
			}else{
				xmlFinal = eliminaTag(xmlStr);
			}
			

			try {
				respuesta.setString(1, xmlFinal);
				return respuesta;
			} catch (SQLException e) {
				throw new RuntimeException("Error al intentar guardar la cadena en el CLOB: " + xmlFinal, e);
			}
		} finally {
			if (urlc != null) {
				urlc.disconnect();
			}
			if (salida != null) {
				try {
					salida.close();
				} catch (IOException e) {
				}
			}
			if (entrada != null) {
				try {
					entrada.close();
				} catch (IOException e) {
				}
			}
		}
	}

	public static String eliminaTag(StringBuffer xml) {
		try {
			return xml.substring(xml.indexOf("<", xml.indexOf("env:Body>")), xml.indexOf("</env:Body></env:Envelope>"));
		} catch (Exception e) {
			throw new RuntimeException("Error JavaServicioWeb: No se pudo eliminar Tags en la  respuesta: " + xml
					+ " \n" + e.getMessage());
		}
	}
	
	public static String readClob(Clob clob) {
		try {
			StringBuilder sb = new StringBuilder((int) clob.length());
			Reader r = clob.getCharacterStream();
			char[] cbuf = new char[2048];
			int n;
			while ((n = r.read(cbuf, 0, cbuf.length)) != -1) {
				sb.append(cbuf, 0, n);
			}
			return sb.toString();
		}catch(Exception e) {
			throw new RuntimeException("Error JavaServicioWeb: No se pudo convertir el input clob a string: " 
					+ " \n" + e.getMessage());
		}
		
	}
};
