declare 
wsdl varchar2(4000);
xml clob:=' ';
res clob:=' ';
begin
wsdl:='http://192.168.1.36:8080/ws/countries.wsdl';
xml:='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:gs="http://spring.io/guides/gs-producing-web-service">
   <soapenv:Header/>
   <soapenv:Body>
      <gs:getCountryRequest>
         <gs:name>Poland</gs:name>
      </gs:getCountryRequest>
   </soapenv:Body>
</soapenv:Envelope>';
       
 dbms_output.put_line(dbms_lob.getlength(xml));
  res:=fx_java_call_ws(wsdl,xml,res);
  dbms_output.put_line(res); 
end;
