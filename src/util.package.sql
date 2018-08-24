create or replace PACKAGE         UTIL AS
/**
================================================================================
<p>
    <b>Projeto:</b>         "Util's"
</p>
<p>
    <b>Descrição:</b>       Tem como intenção criar as principais funcionalidades para conversão, caso seja "util" acrescentar aqui.
</p>
<p>
    <b>Criato por:</b>      Daniel K. Morita
</p>
<p>
    <b>Data:</b>            02/10/2017
</p>
   
================================================================================
*/
    /* Variables */
    /* Subtipos */
    subtype string_default is varchar2(100);
    subtype max_string     is varchar2(32767);
    subtype min_string     is varchar2(1);
    
/*table, td, th {    
    border: 1px solid #ddd;
    text-align: left;
}

table {
    border-collapse: collapse;
    width: 100%;
}

th, td {
    padding: 15px;
}
* {
 font-family: Arial;
 color:  #3d85c6;
}*/
    mensagem_email varchar2(3000) := 
'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>titulo</title>
    <style>
        * {
            font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
            border-collapse: collapse;
            width: 100%;
        }
        td, th {
            border: 1px solid #ddd;
            padding: 8px;
        }

        tr:nth-child(even){background-color: #f2f2f2;}
        tr:hover {background-color: #ddd;}

        th {
            padding-top: 12px;
            padding-bottom: 12px;
            text-align: left;
            background-color: #4CAF50;
            color: white;
        }
    </style>
</head>
<body>dados_corpo</body></html>';
    
    /* listas */
    type t_array         is table of string_default        index by binary_integer;
    type dados           is table of anydata               index by binary_integer;
    type colunas         is table of dados                 index by string_default;
    type console_colunas is table of user_tab_cols%rowtype index by string_default;
    
    /* Records */
    type console_table is record (head    clob,
                                  line    clob,
                                  row     clob,
                                  colunas console_colunas,
                                  html    clob);
    
    type r_cep is record (nr_cep         ger_ceps.nr_cep%type
                         ,tp_logradouro  ger_ceps.tp_logradouro%type
                         ,nm_logradouro  ger_ceps.nm_logradouro%type
                         ,ds_complemento ger_ceps.ds_complemento%type
                         ,nm_bairro      ger_ceps.nm_bairro1%type
                         ,sg_uf          ger_cidades.sg_uf%type
                         ,nm_localidade  ger_cidades.nm_localidade%type
                         ,sq_cidade      ger_ceps.sq_cidade%type);

    

/**
    Print varchar2
*/
    procedure p(txt varchar2, p_debug boolean default true);
/**
    Print clob
*/
    procedure plob(txt clob, size_line varchar2 default ('200'), p_debug boolean default true);
/**
    Mostrar o erro do "bloco" atual
*/
    procedure show_erro;
/**
    Retorno o erro do "bloco" atual
*/
    function get_erro return clob;

/*
================================================================================
                    Manipular variáveis
================================================================================
*/

/**
    Substituir todos os números
    @param  p_txt   texto a ser tratado
    @param  p_by    valor a ser substituido
*/
    function replace_all_number(p_txt varchar2, p_by varchar2) return varchar2;
    function replace_all_number(p_num number, p_by varchar2) return number;
/**
    Substituir todo o alfabeto
    @param  p_txt   texto a ser tratado
    @param  p_by    valor a ser substituido
*/
    function replace_all_string(p_txt varchar2, p_by varchar2) return varchar2;
/**
    Substituir todos caracteres especiais
    @param  p_txt   texto a ser tratado
    @param  p_by    valor a ser substituido
*/
    function replace_all_special(p_txt varchar2, p_by varchar2) return varchar2;
/**
    Substituir tudo por @p_by
    @param  p_txt   texto a ser tratado
    @param  p_by    valor a ser substituido
*/
    function replace_all(p_txt varchar2, p_by varchar2) return varchar2;
    

/**
    Verifica se existe a string desejada
        
    @param  P_LISTA     onde buscar
    @param  P_STRING    a ser procurado
    @param  P_IDENTICAL valores identicos
    
    @return caso exista retorna true senão false
    
*/
    function str_exists(p_lista t_array, p_string varchar2, p_identical boolean default true) return boolean;

/**
    Remover todos os caracteres especiais
    
    <pre>No parâmetro p_keep passar *@+_!</pre>
    
    @param  p_string    onde remover
    @param  p_keep      manter se quer manter algum caracter passar sem espaços;
    
    @return string sem caracteres especiais
*/
    function remove_all_special_character(p_string clob, p_keep varchar2 default null) return clob;
/**
    Remover todos os caracteres especiais
    
    <pre>No parâmetro p_keep passar *@+_!</pre>
    
    @param  p_string    onde remover
    @param  p_keep      manter se quer manter algum caracter passar sem espaços;
    
    @return string sem caracteres especiais
*/
    function remove_all_special_character(p_string varchar2, p_keep varchar2 default null) return varchar2;
/**
    Remover linhas em uma string
    
    @param  p_string    onde remover
    
    @return string sem as linhas
*/    
    function remove_lines(p_string clob) return clob;
/**
    Remover linhas em uma string
    
    @param  p_string    onde remover
    
    @return string sem as linhas
*/    
    function remove_lines(p_string varchar2) return varchar2;
/**
    Remover acentos
    
    @param  p_string    onde remover
    
    @return string sem acentos
*/
    function remove_acentos(p_string in varchar2) return varchar2;
   
/*
    Manter apenas números e retornar
    
    @param string texto a ser verificado
    
    @return apenas números
*/
    function keep_number(string in varchar2) return number;
/*
    Manter apenas string
    
    @param  string  texto a ser verificado
    
    @return apenas alfabeto 
*/
    function keep_string(string in varchar2) return varchar2;
    
/**
    Verifica se existe caracteres especiais
    
    @param  p_string    onde buscar
    @param  p_except    exceções
    
    @return caso tenha encontrado retorna true senão false
*/
    function has_special_character(p_string varchar2, p_except varchar2 default null) return boolean;
    
    function has_number(p_string varchar2) return boolean;
    
/**
    Verifica se contém a string desejada
    
    @param  p_str       onde buscar
    @param  p_string    a ser procurado
    
    @return caso contém p_string em p_str então retorna true senão false
*/
    function contains(p_str varchar2, p_string varchar2) return boolean;

/**
    Converter UNICODE para String, utilizando função do oracle,<em>UNISTR</em>.
    A função <em>UNISTR</em> converte literal de cadeia de strings que contém 
    pontos de código unicode, são representados por <em>'hhhh'</em> (hhhh é valor hex) 
    tbm são caracteres comuns da cadeia unicode.
    
    @param  p_unicode   string unicode a ser convertido.
    @return <b>@p_unicode</b> convertido.

*/
    function convert_unicode_to_string(p_unicode varchar2) return varchar2;
/*
    Separar em lista por delimitador ou sem, quando ser irá separar por
    caracter.
    
    @param  p_in_string     texto a ser separado 
    @param  p_delim         quebra na lista, delimitador
    @param  p_keep_delim    manter o delimitador?
    
    @return t_array resultado, lista contendo todos os valores na lista
*/
    function split (p_in_string varchar2, p_delim varchar2 default null, p_keep_delim boolean default true) return t_array;

/**
    Formatar data.
    @param  p_date      data a ser formatada.
    @param  p_format    formato da data desejada.
    @return string da data formatada.
*/    
    function format_date(p_date date, p_format varchar2 default 'dd/mm/rrrr') return varchar2;

/**
    Adicionar n minutos na data
    @param  p_date  data a ser acrescentada
    @param  n       n minutos
    @return data com n minutos a mais
*/
    function add_minutes(p_date date, n integer) return date;
/**
    Adicionar n horas na data
    @param  p_date  data a ser acrescentada
    @param  n       n horas
    @return data com n horas a mais
*/
    function add_hours(p_date date, n integer) return date;
/**
    Retorna a string da variavel anydata
    @param  p_anydata   anydata a ser convertida
    @return string de @p_anydata
*/
    function get_anydata_value(p_anydata anydata) return varchar2;
    
/*
================================================================================
                    Manipular Tabelas/DML/DDL
================================================================================
*/

/**
    Criado para executar blocos PL/SQL com DBMS_SQL.
    
    @param  string  bloco a ser executado.
*/
    procedure exec(string IN varchar2);
/**
    Executa a procedure exec e mostra o tempo
    @param  string  bloco a ser executado.
*/
    procedure exec_time(string IN varchar2) ;
/**
    TODO
    @param  string  bloco a ser executado.
*/
    procedure exec_bulk (p_colunas colunas, p_ddl varchar2);
/**
    Dropa objetos
    @param  type_in tipo do objeto (table, procedure, funciton, etc...)
    @param  name_in nome do objeto
*/
    procedure drop_object(type_in IN VARCHAR2, name_in IN VARCHAR2);

/**
    Atualizar tabela conforme informações passadas por parâmetros.
    
    @param  p_nm_table  nome da tabela a ser atualizada.
    @param  p_columns   colunas que irão ser atualizadas.
    @param  p_wheres    condições para atualização.
    @return caso ocorra com sucesso retornará true senão false. 
    
*/
    function update_table(p_nm_table varchar2, p_columns colunas, p_wheres colunas) return boolean;
    
/*
    Executar sql.
    
    @param  p_sql   comando a ser executado.
    @return se executou com sucesso retorna true se não false.
    
*/
    function exec(p_sql varchar2) return boolean;

/*
================================================================================
                    Prints no terminal/console/dbms_output
================================================================================
*/

/**
    Exibe a descrição da tabela
    @param  p_nm_table  nome da tabela
*/
    procedure show_describe_table(p_nm_table varchar2);
    
/**
    Retorna o objeto console_table conforme tabela desejada
    @param  p_nm_table nome da tabela
    @return  objeto console_table
*/
    function get_console_table(p_nm_table varchar2) return console_table;
/**
    Retorna o objeto console_table conforme <b>json</b> informado.
    
    @param  p_json      objeto json a ser convertido
    @param  p_nm_table  nome da tabela
    @return  objeto console_table
*/
    function get_console_table(p_json pljson, p_nm_table varchar2, is_html boolean default false) return console_table;
/**
    Exemplo testando o tipo <em>"console_table"</em>
    @param p_sql
*/
    procedure show_console_table_example;
/**
    Printa no <b>terminal/console/dbms_output</b> os dados da tabela.
    
    @param  p_sql       select a ser printado
    @param  p_nm_tabela nome da tabela
    @param  all_columns printar todas as colunas?
*/
    procedure show_table_on_console(p_sql varchar2, p_nm_tabela varchar2, all_columns boolean default true);
    function get_table_on_console(p_sql varchar2, p_nm_tabela varchar2, all_columns boolean default true, is_html boolean default false) return clob;
    
/*
================================================================================
                    Job Schedule service
================================================================================
*/
/**
    Scheduling Jobs with Oracle Scheduler
    
    select *
  from ALL_SCHEDULER_JOBS
 WHERE JOB_NAME = 'JOB_CANVAS'
 union all 
SELECT * 
  FROM DBA_SCHEDULER_JOBS c
 WHERE JOB_NAME = 'JOB_CANVAS';
 
 SELECT *
  FROM DBA_TABLES
 where table_name like '%JOBS%';

SELECT * FROM ALL_SCHEDULER_RUNNING_JOBS;

SELECT * FROM ALL_SCHEDULER_RUNNING_CHAINS WHERE JOB_NAME='JOB_CANVAS';

*/

/**
    Criar novo JOB
    
    @param  p_job_name          nome do job
    @param  p_job_type          tipo d job, valores validos ('PLSQL_BLOCK', 'STORED_PROCEDURE', 'EXECUTABLE', 'CHAIN', 'EXTERNAL_SCRIPT', 'SQL_SCRIPT', 'BACKUP_SCRIPT')
    @param  p_job_action        ação que será executado
    @param  p_start_date        data de inicio
    @param  p_repeat_interval   informar o intervalo de repetição
    @param  p_end_date          data final
    @param  p_job_class         nome da classe do Job
    @param  p_comments          comentario
*/
    procedure job_create(p_job_name varchar2, p_job_type varchar2, p_job_action varchar2, p_start_date varchar2, p_repeat_interval varchar2, p_end_date varchar2 default null, p_job_class varchar2 default 'DEFAULT_JOB_CLASS', p_comments varchar2 default null);
/**
    Alterar JOB
    
    @param  p_job_name          nome do job
    @param  p_attribute         nome do atributo a ser alterado
    @param  p_value             valor a ser alterado
*/
    procedure job_alter(p_nm_job varchar2, p_attribute varchar2, p_value varchar2);
/**
    Parar JOB  
    @param  p_job_name          nome do job
*/
    procedure job_stop(p_nm_job varchar2);
/**
    Habilitar JOB  
    @param  p_job_name          nome do job
*/
    procedure job_enable(p_nm_job varchar2);
/**
    Desabilitar JOB  
    @param  p_job_name          nome do job
*/
    procedure job_disable(p_nm_job varchar2);
/**
    Rodar JOB  
    @param  p_job_name          nome do job
*/
    procedure job_run(p_nm_job varchar2);
/**
    Remover/dropar/excluir JOB  
    @param  p_job_name          nome do job
*/
    procedure job_drop(p_nm_job varchar2);
/**
    Copiar JOB  
    @param  p_old_job   nome do job a ser copiado.
    @param  p_new_job   nome novo do job.
*/
    procedure job_copy(p_old_job varchar2, p_new_job varchar2);

/**
    Buscar job na tabela de jobs rodando, caso encontrei retorna verdairo.
    @param  p_job_name  nome do job.
    @return true se encontrar senão false
*/
    function job_is_runnig(p_job_name in varchar2) return boolean;

/*
================================================================================
                    Util
================================================================================
*/

/*  
    Função para validar CPF/CNPJ
    
    @param  v_cpf_cnpj
    @return true/false valido/invalido
*/  
    function valida_cpf_cnpj(v_cpf_cnpj varchar2) return boolean;
    
/**
    Enviar e-mail
    @param  p_para      remetente
    @param  p_cc        (opcional) cc, separar por ";"
    @param  p_assunto   assunto do email
    @param  p_mensagem  mensagem (html/texto)
*/
    procedure send_email(p_para varchar2 default 'wpiornedo@unifil.br', p_cc varchar2 default null, p_assunto varchar2, p_mensagem clob);

/**
    Pega a informação do terminal.
    @return Retorna o terminal corrente.
*/
    function get_terminal return varchar2;

/**
    Pega o usuario logado na sessão do bd 
    @return nome do usuário logado na sessão oracle
*/
    function get_user return varchar2;
    
/**
    Retorna informações do CEP
    
    @param  p_nr_cep    CEP
    @return r_cep
*/
    function get_cep(p_nr_cep number) return r_cep;
    
/**
    <p>
    Faz a busca do cep no WebService, no momento utiliza duas APIs,
    <em>postmon</em> e <em>viacep</em>, caso não encontre na primeira
    url, busca na segundo e assim por diante, nesta função também realiza 
    a inserção na tabela <b>GER_CEPS</b> caso o cep não exista.
    </p>

    <p>
        Exemplo de utilização:
        <pre>
            <code>
                declare
                    cep util.r_cep;
                begin
                    cep := util.find_cep_by_webservice('86050350');
                end;
            </code>
        </pre>
    </p>
    
    @param  pNR_CEP     cep a ser buscado.
    return tipo record declarado no spec deste pacote.
*/
    function find_cep_by_webservice  (pNR_CEP in varchar2) return r_cep;

    
/**
    Executar comandos OS via JAVA (Host_command3), 
    nesse caso foi criado um script (no servidor) que realiza a requisição, através do comando <i>curl</i> e
    retorna em string o resultado.
    
    @param  p_script    arquivo/script a ser utilizado para a chamadas das requisições
    @param  p_action    ação a ser requisitado (GET, POST, PUT, etc)
    @param  p_method    metodo da chamada da requisição
    @param  p_json      quando há persistência deve informar
    @param  r_json      <b>retorna</b> o resultado da requisição, ler documentação para mais detalhes
    @param  r_msg       <b>retorna</b> as informações para o log
    
*/
    procedure execute_hostcommand(p_script varchar2, p_action in varchar2, p_method in varchar2, p_json in clob default null, r_json out clob, r_msg out clob);
    
    function teste return varchar2;
END UTIL;
/

create or replace PACKAGE BODY         UTIL AS

    debug boolean := true;
    
    procedure p(txt varchar2, p_debug boolean default true) is begin if p_debug then dbms_output.put_line(txt); end if; end;
    procedure plob(txt clob, size_line varchar2 default ('200'), p_debug boolean default true) is begin if p_debug then PLJSON_PRINTER.DBMS_OUTPUT_CLOB(txt, size_line); end if; end;
    
    procedure show_erro is begin
        plob(get_erro);
    end;
    
    function get_erro return clob is
        retorno clob;
    begin
        return DBMS_UTILITY.FORMAT_ERROR_STACK || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
    end;

/*
================================================================================
                    Manipular variáveis
================================================================================
*/

    function replace_all_number(p_txt varchar2, p_by varchar2) return varchar2 is begin
        return REGEXP_REPLACE(p_txt, '[[:digit:]]', p_by);
    end;
    
    function replace_all_number(p_num number, p_by varchar2) return number is begin
        return REGEXP_REPLACE(p_num, '[[:digit:]]', p_by);
    end;
    
    function replace_all_string(p_txt varchar2, p_by varchar2) return varchar2 is begin
        return REGEXP_REPLACE(p_txt, '[[:alpha:]]', p_by);
    end;
    
    function replace_all_special(p_txt varchar2, p_by varchar2) return varchar2 is begin
        return REGEXP_REPLACE(p_txt, '[[:punct:]]', p_by);
    end;
    
    function replace_all(p_txt varchar2, p_by varchar2) return varchar2 is begin
        if has_number(p_txt) then
            return replace_all_special(replace_all_number(replace_all_string(p_txt, p_by), p_by), p_by);
        else
            return replace_all_special(replace_all_string(p_txt, p_by), p_by);
        end if;
    end;
    
    function str_exists(p_lista t_array, p_string varchar2, p_identical boolean default true) return boolean is begin
        for i in 1..p_lista.last loop
            if p_identical then
                if p_lista(i) = p_string then
                    return true;
                end if;
            else
                if p_lista(i) like '%' || p_string || '%' then
                    return true;
                end if;
            end if;
        end loop;
        return false;
    end;
    
    function remove_lines(p_string clob) return clob is begin
        return replace(
           replace(
               replace(p_string, chr(10), '')
           , chr(13), '')
       , chr(09), '');
    end;
    
    function remove_lines(p_string varchar2) return varchar2 is begin
        return replace(
           replace(
               replace(p_string, chr(10), '')
           , chr(13), '')
       , chr(09), '');
    end;
   
    function remove_all_special_character(p_string clob, p_keep varchar2 default null) return clob as
        li t_array;
        li_manter t_array;
        novo clob;
    begin         
        if p_keep is null then
            if has_special_character(p_string) then
                return regexp_replace(p_string,'[[:punct:]]','');
            else
                return p_string;
            end if;
        else
            li := split(p_string);
            li_manter := split(p_keep);
            for i in 1..li.last loop
                if str_exists(li_manter, li(i)) then
                    novo := novo || li(i);
                else
                    novo := novo || remove_all_special_character(li(i));
                end if;
                
            end loop;
            return coalesce(novo, '');
        end if;
    end;
    
    function remove_all_special_character(p_string varchar2, p_keep varchar2 default null) return varchar2 as
        li t_array;
        li_manter t_array;
        novo varchar2(4000);
    begin         
        if p_keep is null then
            if has_special_character(p_string) then
                return regexp_replace(p_string,'[[:punct:]]','');
            else
                return p_string;
            end if;
        else
            li := split(p_string);
            li_manter := split(p_keep);
            for i in 1..li.last loop
                if str_exists(li_manter, li(i)) then
                    novo := novo || li(i);
                else
                    novo := novo || remove_all_special_character(li(i));
                end if;
                
            end loop;
            return coalesce(novo, '');
        end if;
    end;

    function remove_acentos(p_string in varchar2) return varchar2 is
        l_string_retorno varchar2(2000); 
    begin
        l_string_retorno := translate( p_string,'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜáçéíóúàèìòùâêîôûãõëü','ACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeu');
        return l_string_retorno;
    end;
    
    function keep_number(string in varchar2) return number is begin
        return to_number(regexp_replace(string, '[^[:digit:]]+',''));
    end;

    function keep_string(string in varchar2) return varchar2 is begin
        return regexp_replace(string, '[^[:alpha:]]+','');
    end;
    
    function has_number(p_string varchar2) return boolean as begin
        if REGEXP_LIKE(p_string, '[[:digit:]]') then
            return true;
        else
            return false;
        end if;
    end;

    function has_special_character(p_string varchar2, p_except varchar2 default null) return boolean as
        ln_bill_no  varchar2(100);
        ln_length   number          := 0;
        l_keep      varchar2(100)   := '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        l_tmp       varchar2(100)   := '000000000000000000000000000000000000';
    begin         
        ln_bill_no := p_string;
        if(ln_bill_no is not null) then
            if p_except is not null then
                l_keep := l_keep||p_except;
                for i in 1..length(p_except) loop
                    l_tmp := l_tmp ||'0';
                end loop;
            end if;
            ln_length  := length(replace(translate(upper(ln_bill_no),l_keep,l_tmp),'0',''));
            if( nvl(ln_length,0) > 0) then
                return true;
            else
                return false;
            end if;
        end if;
        return false;
    end;
    
    function contains(p_str varchar2, p_string varchar2) return boolean is begin
        if p_str like '%' || p_string || '%' then
            return true;
        end if;
        return false;
    end;
    
    function convert_unicode_to_string(p_unicode varchar2) return varchar2 is begin
        if p_unicode like '%\u%' then
            return UNISTR(replace(p_unicode, '\u', '\'));
        else
            return UNISTR(p_unicode);
        end if;
    end;
    
    function split (p_in_string varchar2, p_delim varchar2 default null, p_keep_delim boolean default true) return t_array is 

        i       number := 0; 
        pos     number := 0; 
        lv_str  max_string := p_in_string; 

        strings t_array; 

    begin 

        if p_delim is null then
            pos := 1;
        else
            pos := instr(lv_str,p_delim,1,1);
        end if;
         
        while ( pos != 0) loop 

            i := i + 1; 
            if p_delim is null then
                strings(i) := to_char(substr(lv_str,1,pos));
            else
                if p_keep_delim then
                    strings(i) := to_char(substr(lv_str,1,pos));
                else
                    strings(i) := substr(lv_str,1,pos - 1);
                end if;
                
            end if;
            
            lv_str := substr(lv_str,pos+1,length(lv_str));
            
            if p_delim is null then
                pos := instr(lv_str,substr(lv_str, pos, 1),1,1);
            else
                pos := instr(lv_str,p_delim,1,1); 
            end if;
            
            if pos = 0 then 
                strings(i+1) := lv_str; 
            end if; 

        end loop; 

        return strings; 

    end split;
    
    function format_date(p_date date, p_format varchar2 default 'dd/mm/rrrr') return varchar2 is begin
        return to_char(p_date, p_format);
    end;
    
    function add_minutes(p_date date, n integer) return date is
        w_date date;
    begin
        w_date := p_date + (1/1440*n);
        return w_date; 
    end;
    
    function add_hours(p_date date, n integer) return date is
        w_date date;
    begin
        w_date := p_date + (1/24*n);
        return w_date; 
    end;
    
    function get_anydata_value(p_anydata anydata) return varchar2 is
        w_nm_type varchar2(100);
    begin
        w_nm_type := replace(ANYDATA.GETTYPENAME(p_anydata), 'SYS.', '');
        if upper(w_nm_type) = 'VARCHAR2' then
            return anydata.AccessVarchar2(p_anydata);
        else
            return null;
        end if;

    end;
    
/*
================================================================================
                    Manipular Tabelas/DML/DDL
================================================================================
*/
    function exec(p_sql varchar2) return boolean is
        c           NUMBER;
        d           NUMBER;
        is_updated  boolean := false;
    begin
        c := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(c, p_sql, DBMS_SQL.NATIVE);
        d := DBMS_SQL.EXECUTE(c);
        if d > 0 then
            is_updated := true;
        end if;
        DBMS_SQL.CLOSE_CURSOR(c);
        return is_updated;
        exception 
            when others then
                IF DBMS_SQL.IS_OPEN(c) THEN
                    DBMS_SQL.CLOSE_CURSOR(c);
                END IF;
                p(get_erro);
--                raise;
                return is_updated;
    end exec;
    
    PROCEDURE exec(string IN varchar2) AS
        cursor_name INTEGER;
        ret INTEGER;
    BEGIN
       cursor_name := DBMS_SQL.OPEN_CURSOR;
       p('exec: '||string, debug);
    --DDL statements are run by the parse call, which performs the implied commit.

       DBMS_SQL.PARSE(cursor_name, string, DBMS_SQL.NATIVE);
       ret := DBMS_SQL.EXECUTE(cursor_name);
       DBMS_SQL.CLOSE_CURSOR(cursor_name);
       exception
        when others then
            IF DBMS_SQL.IS_OPEN(cursor_name) THEN 
                DBMS_SQL.CLOSE_CURSOR(cursor_name); 
            END IF;
            show_erro;
--            RAISE; 
    END;

    PROCEDURE exec_time(string IN varchar2) AS
       time_before BINARY_INTEGER;
       time_after BINARY_INTEGER;
    BEGIN
       time_before := DBMS_UTILITY.GET_TIME;
       exec(string);
       time_after := DBMS_UTILITY.GET_TIME;
       p ('Tempo de execução:'|| (time_after - time_before));
    END;
    
--@DEPRECATED
    function DEPRECATED_execute_sql(p_sql varchar2) return boolean is begin
        execute immediate p_sql;
        if sql%rowcount > 0 then
            return true;
        else
            return false;
        end if;
    end DEPRECATED_execute_sql;
    
 -- DBMS_SQL 
    procedure exec_bulk (p_colunas colunas, p_ddl varchar2) is
--    stmt VARCHAR2(200);
--    empno_array      DBMS_SQL.NUMBER_TABLE;
--    empname_array    DBMS_SQL.VARCHAR2_TABLE;
--    jobs_array       DBMS_SQL.VARCHAR2_TABLE;
--    mgr_array        DBMS_SQL.NUMBER_TABLE;
--    hiredate_array   DBMS_SQL.VARCHAR2_TABLE;
--    sal_array        DBMS_SQL.NUMBER_TABLE;
--    comm_array       DBMS_SQL.NUMBER_TABLE;
--    deptno_array     DBMS_SQL.NUMBER_TABLE;
--    c                NUMBER;
--    dummy            NUMBER;
        
        w_nm_coluna varchar2(100);
    BEGIN

        w_nm_coluna := p_colunas.first;
        while w_nm_coluna is not null loop
            
            declare
            begin
                for i in 1..p_colunas(w_nm_coluna).last loop
                    p(anydata.GETTYPENAME(p_colunas(w_nm_coluna)(i)));
                end loop;
            end;
            
            w_nm_coluna := p_colunas.next(w_nm_coluna);
        end loop;
        
--    empno_array(1):= 9001;
--    empno_array(2):= 9002;
--    empno_array(3):= 9003;
--    empno_array(4):= 9004;
--    empno_array(5):= 9005;
--    empno_array(6):= 9006;
--    empno_array(7):= 9007;
--
--    empname_array(1) := 'Dopey';
--    empname_array(2) := 'Grumpy';
--    empname_array(3) := 'Doc';
--    empname_array(4) := 'Happy';
--    empname_array(5) := 'Bashful';
--    empname_array(6) := 'Sneezy';
--    empname_array(7) := 'Sleepy';
--
--    jobs_array(1) := 'Miner';
--    jobs_array(2) := 'Miner';
--    jobs_array(3) := 'Miner';
--    jobs_array(4) := 'Miner';
--    jobs_array(5) := 'Miner';
--    jobs_array(6) := 'Miner';
--    jobs_array(7) := 'Miner';
--
--    mgr_array(1) := 9003;
--    mgr_array(2) := 9003;
--    mgr_array(3) := 9003;
--    mgr_array(4) := 9003;
--    mgr_array(5) := 9003;
--    mgr_array(6) := 9003;
--    mgr_array(7) := 9003;
--
--    hiredate_array(1) := '06-DEC-2006';
--    hiredate_array(2) := '06-DEC-2006';
--    hiredate_array(3) := '06-DEC-2006';
--    hiredate_array(4) := '06-DEC-2006';
--    hiredate_array(5) := '06-DEC-2006';
--    hiredate_array(6) := '06-DEC-2006';
--    hiredate_array(7) := '06-DEC-2006';
--
--    sal_array(1):= 1000;
--    sal_array(2):= 1000;
--    sal_array(3):= 1000;
--    sal_array(4):= 1000;
--    sal_array(5):= 1000;
--    sal_array(6):= 1000;
--    sal_array(7):= 1000;
--
--    comm_array(1):= 0;
--    comm_array(2):= 0;
--    comm_array(3):= 0;
--    comm_array(4):= 0;
--    comm_array(5):= 0;
--    comm_array(6):= 0;
--    comm_array(7):= 0;
--
--    deptno_array(1):= 11;
--    deptno_array(2):= 11;
--    deptno_array(3):= 11;
--    deptno_array(4):= 11;
--    deptno_array(5):= 11;
--    deptno_array(6):= 11;
--    deptno_array(7):= 11;
--    
--    stmt := 'INSERT INTO emp VALUES(
--    :num_array, :name_array, :jobs_array, :mgr_array, :hiredate_array, 
--    :sal_array, :comm_array, :deptno_array)';
--    c := DBMS_SQL.OPEN_CURSOR;
--    DBMS_SQL.PARSE(c, stmt, DBMS_SQL.NATIVE);
--    DBMS_SQL.BIND_ARRAY(c, ':num_array', empno_array);
--    DBMS_SQL.BIND_ARRAY(c, ':name_array', empname_array);
--    DBMS_SQL.BIND_ARRAY(c, ':jobs_array', jobs_array);
--    DBMS_SQL.BIND_ARRAY(c, ':mgr_array', mgr_array);
--    DBMS_SQL.BIND_ARRAY(c, ':hiredate_array', hiredate_array);
--    DBMS_SQL.BIND_ARRAY(c, ':sal_array', sal_array);
--    DBMS_SQL.BIND_ARRAY(c, ':comm_array', comm_array);
--    DBMS_SQL.BIND_ARRAY(c, ':deptno_array', deptno_array);
--
--    dummy := DBMS_SQL.EXECUTE(c);
--    DBMS_SQL.CLOSE_CURSOR(c);
--    EXCEPTION WHEN OTHERS THEN
--    IF DBMS_SQL.IS_OPEN(c) THEN
--    DBMS_SQL.CLOSE_CURSOR(c);
--    END IF;
--    RAISE;
    END;
    
    procedure drop_object(type_in IN VARCHAR2, name_in IN VARCHAR2) 
    IS
        /* The static cursor retrieving all matching objects */
        CURSOR obj_cur IS
            SELECT object_name, object_type
              FROM user_objects
             WHERE object_name LIKE UPPER (name_in)
               AND object_type LIKE UPPER (type_in)
             ORDER BY object_name;

        cur PLS_INTEGER := DBMS_SQL.OPEN_CURSOR;
        fdbk PLS_INTEGER;
    BEGIN
        /* For each matching object ... */
        FOR obj_rec IN obj_cur LOOP
            p('DROP ' || obj_rec.object_type || ' ' || obj_rec.object_name, debug);
        /* Reusing same cursor, parse and execute the drop statement. */
        DBMS_SQL.PARSE 
            (cur, 
            'DROP ' || obj_rec.object_type || ' ' || obj_rec.object_name, 
            DBMS_SQL.NATIVE);

        fdbk := DBMS_SQL.EXECUTE (cur);
        END LOOP;
        DBMS_SQL.CLOSE_CURSOR (cur);
    END;
    
    function update_table(p_nm_table varchar2, p_columns colunas, p_wheres colunas) return boolean is
        c number;
        n number;
        w_colunas varchar2(1500);
        w_nm_coluna varchar2(100);
        w_sql_update varchar2(1000);
    begin
        w_sql_update := 'UPDATE '||p_nm_table||' SET ';
        w_nm_coluna := p_columns.first;
        while w_nm_coluna is not null loop
            w_sql_update := w_sql_update || w_nm_coluna || ' = :c' || w_nm_coluna || ' , '; 
            w_nm_coluna := p_columns.next(w_nm_coluna);
        end loop;
        w_sql_update := substr(w_sql_update, -2);
        
        w_nm_coluna := p_wheres.first;
        if w_nm_coluna is not null then
            w_sql_update := w_sql_update || ' where ';
        end if;
        while w_nm_coluna is not null loop
            w_sql_update := w_sql_update || w_nm_coluna || ' = :w' || w_nm_coluna || ' and '; 
            w_nm_coluna := p_wheres.next(w_nm_coluna);
        end loop;
        w_sql_update := substr(w_sql_update, -4);
        --util.p('dao_update_table:'||chr(10)||w_sql_update);
        c := dbms_sql.open_cursor;
        dbms_sql.parse(c, w_sql_update, dbms_sql.native);
        
        w_nm_coluna := p_columns.first;
        while w_nm_coluna is not null loop
            DBMS_SQL.BIND_VARIABLE(c, 'c'||w_nm_coluna, p_columns(w_nm_coluna)(1));
            w_nm_coluna := p_columns.next(w_nm_coluna);
        end loop;
        w_sql_update := substr(w_sql_update, -2);
        
        w_nm_coluna := p_wheres.first;
        while w_nm_coluna is not null loop
            DBMS_SQL.BIND_VARIABLE(c, 'w'||w_nm_coluna, p_wheres(w_nm_coluna)(1)); 
            w_nm_coluna := p_wheres.next(w_nm_coluna);
        end loop;
        
        n := dbms_sql.execute(c); 
--        dbms_sql.variable_value(c, 'bnd3', r);-- get value of outbind variable
        dbms_sql.close_cursor(c);
    end;
    
/*
================================================================================
                    Prints no terminal/console/dbms_output
================================================================================
*/
    procedure show_describe_table(p_nm_table varchar2) is
        c           NUMBER;
        d           NUMBER;
        col_cnt     INTEGER;
        f           BOOLEAN;
        rec_tab     DBMS_SQL.DESC_TAB;
        col_num    NUMBER;
        PROCEDURE print_rec(rec in DBMS_SQL.DESC_REC) IS
        BEGIN
            DBMS_OUTPUT.NEW_LINE;
            DBMS_OUTPUT.PUT_LINE('col_type            =    '
                     || rec.col_type);
            DBMS_OUTPUT.PUT_LINE('col_maxlen          =    '
                     || rec.col_max_len);
            DBMS_OUTPUT.PUT_LINE('col_name            =    '
                     || rec.col_name);
            DBMS_OUTPUT.PUT_LINE('col_name_len        =    '
                     || rec.col_name_len);
            DBMS_OUTPUT.PUT_LINE('col_schema_name     =    '
                     || rec.col_schema_name);
            DBMS_OUTPUT.PUT_LINE('col_schema_name_len =    '
                     || rec.col_schema_name_len);
            DBMS_OUTPUT.PUT_LINE('col_precision       =    '
                     || rec.col_precision);
            DBMS_OUTPUT.PUT_LINE('col_scale           =    '
                     || rec.col_scale);
            DBMS_OUTPUT.PUT('col_null_ok         =    ');
            IF (rec.col_null_ok) THEN
            DBMS_OUTPUT.PUT_LINE('true');
            ELSE
            DBMS_OUTPUT.PUT_LINE('false');
            END IF;
        END;
    BEGIN
        c := DBMS_SQL.OPEN_CURSOR;

        DBMS_SQL.PARSE(c, 'SELECT * FROM '||p_nm_table, DBMS_SQL.NATIVE);

        d := DBMS_SQL.EXECUTE(c);

        DBMS_SQL.DESCRIBE_COLUMNS(c, col_cnt, rec_tab);

        /*
        * Following loop could simply be for j in 1..col_cnt loop.
        * Here we are simply illustrating some of the PL/SQL table
        * features.
        */
        col_num := rec_tab.first;
        IF (col_num IS NOT NULL) THEN
        LOOP
        print_rec(rec_tab(col_num));
        col_num := rec_tab.next(col_num);
        EXIT WHEN (col_num IS NULL);
        END LOOP;
        END IF;

        DBMS_SQL.CLOSE_CURSOR(c);
    END;

/**
    <p>Seta as várivas que serão utilizadas na <em>procedure show_table_on_console</em>,
    para setar irá utilizar os dados da tabela <b>user_tab_cols</b>, podendo assim
    determinar o tamanho e os nomes das colunas a serem usadas.</p>
    
    @param  colunas tipo user_tab_cols
    @param  r_head  cabeçalho da tabela
    @param  r_line  linhas para divisão
    @param  r_row   onde irão os dados da tabela
    @return colunas 
    @return r_head 
    @return r_line 
    @return r_row  
    
*/
    procedure set_console_table(colunas in user_tab_cols%rowtype, r_head out clob, r_line out clob, r_row out clob) is begin
    
        r_head := rpad(colunas.column_name, case when colunas.data_length < length(colunas.column_name) then length(colunas.column_name) else colunas.data_length end, ' ') ||' | ';
        r_line := rpad(replace_all(colunas.column_name, '-'), case when colunas.data_length < length(colunas.column_name) then 
                                                            length(colunas.column_name) 
                                                       else colunas.data_length end, '-') ||' | ';
        r_row := colunas.column_name||' | ';
        
    end;
    
    function get_console_table(p_nm_table varchar2) return console_table is
        
--        r_c c_colunas%rowtype;
        v_head clob;
        v_line clob;
        v_row  clob;
        aux_head clob;
        aux_line clob;
        aux_row  clob;
        v_console_colunas console_colunas;
        r_console_table   console_table;
    begin
        v_head := '' || chr(10) || '| ';
        v_line := '' || chr(10) || '| ';
        v_row := '' || chr(10) || '| ';
    --    rpad(colunas.column_name, colunas.data_length, '')
        for colunas in (SELECT *
                          FROM user_tab_cols
                         WHERE table_name = p_nm_table) loop
            if colunas.data_type = 'DATE' then
                colunas.data_length := 20;
            else
                colunas.data_length := case when colunas.data_length < length(colunas.column_name) then length(colunas.column_name) else colunas.data_length end;
            end if;
             
            set_console_table(colunas, aux_head, aux_line, aux_row);
            v_head := v_head || aux_head; 
            v_line := v_line || aux_line;
            v_row  := v_row  || aux_row;
            
            v_console_colunas(upper(colunas.column_name)) := colunas;
        end loop;
        
        r_console_table.head    := v_head;
        r_console_table.line    := remove_lines(remove_all_special_character(v_line, '|-'));
        r_console_table.row     := v_row;
        r_console_table.colunas := v_console_colunas;
        
        return r_console_table; 
    end;
    
    
    function get_console_table(p_json pljson, p_nm_table varchar2, is_html boolean default false) return console_table is
        v_head clob;
        v_line clob;
        v_row  clob;
        aux_head clob;
        aux_line clob;
        aux_row  clob;
        v_console_colunas console_colunas;
        r_console_table console_table;
        
        colunas user_tab_cols%rowtype;
    begin
        if is_html then
            r_console_table.html := mensagem_email;
            v_head    := '<thead><tr>';
            
            for colunas in (SELECT *
                              FROM user_tab_cols
                             WHERE table_name = p_nm_table) loop
                                 
                if p_json.exist(colunas.column_name) then
                    v_head := v_head || '<td>' || colunas.column_name || '</td>';
                    v_console_colunas(upper(colunas.column_name)) := colunas;
                end if;
                
            end loop; 
            v_head                  := v_head||'</tr></thead>';
            r_console_table.head    := v_head;
            r_console_table.colunas := v_console_colunas;
        else 
            v_head := '' || chr(10) || '| ';
            v_line := '' || chr(10) || '| ';
            v_row := '' || chr(10) || '| ';
            
            for colunas in (SELECT *
                              FROM user_tab_cols
                             WHERE table_name = p_nm_table) loop         
                if p_json.exist(colunas.column_name) then
                    if colunas.data_type = 'DATE' then
                        colunas.data_length := 20;
                    else
                        colunas.data_length := case when colunas.data_length < length(colunas.column_name) then length(colunas.column_name) else colunas.data_length end;
                    end if;
                    set_console_table(colunas, aux_head, aux_line, aux_row);
                    v_head := v_head || aux_head; 
                    v_line := v_line || aux_line;
                    v_row  := v_row  || aux_row;
                    
                    v_console_colunas(upper(colunas.column_name)) := colunas;
                end if;
                
            end loop; 
        
            
            r_console_table.head    := v_head;
            r_console_table.line    := v_line;
            r_console_table.row     := v_row;
            r_console_table.colunas := v_console_colunas;
            
        end if;
        return r_console_table; 
    end;

    procedure show_table_on_console(p_sql varchar2, p_nm_tabela varchar2, all_columns boolean default true) is
        tmp clob;
    begin
        tmp := get_table_on_console(p_sql, p_nm_tabela, all_columns);
        if tmp is not null then
            plob(tmp);
        end if;
    end;
    
    function get_table_on_console(p_sql varchar2, p_nm_tabela varchar2, all_columns boolean default true, is_html boolean default false) return clob is
        w_rows pljson_list;
        w_json pljson;
        
        v_table console_table;
        tmp clob;
        tmp2 clob;
        nm_column varchar2(1000);
        
        procedure popu(p_dado varchar2, p_nm_column varchar2) is
        begin
            tmp := replace(tmp, p_nm_column, rpad(nvl(remove_lines(p_dado), ' '), v_table.colunas(p_nm_column).data_length, ' '));
        end;
        
        procedure popu_html(p_dado varchar2) is
        begin
            tmp := tmp || '<td>'||p_dado||'</td>';
        end;
        
    begin
        
        w_rows := JSON_UTIL_PKG.SQL_TO_JSON(p_sql);
        
        if is_html then
            if w_rows.get(1) is not null then
                v_table := get_console_table(pljson(w_rows.get(1)), upper(p_nm_tabela), is_html);
            end if;
            
            for i in 1..w_rows.count loop
                w_json := pljson(w_rows.get(i));
                tmp := tmp||'<tr>';
                for j in 1..w_json.count loop
                    if w_json.get(j).get_type = 'string' then
                        popu_html(w_json.get(j).str);
                    elsif w_json.get(j).get_type = 'number' then
                        popu_html(w_json.get(j).num);
                    elsif w_json.get(j).get_type = 'bool' then
                        if w_json.get(j).get_bool then
                            popu_html('true');
                        else
                            popu_html('false');
                        end if;
                    elsif w_json.get(j).get_type = 'null' then
                        popu_html(w_json.get(j).get_null);
                    else
                        popu_html('');
                    end if;
                end loop;
                tmp := tmp||'</tr>';
            end loop;
            
            v_table.row := '<tbody>' ||tmp || '</tbody>';
            
            return replace(v_table.html, 'dados_corpo', '<table>'||v_table.head||v_table.row||'</table>'); 
        else
        
            if all_columns then
                v_table := get_console_table(upper(p_nm_tabela));
            else
                if w_rows.get(1) is not null then
                    v_table := get_console_table(pljson(w_rows.get(1)), upper(p_nm_tabela));
                end if;
            end if;
            
            for i in 1..w_rows.count loop
                
                w_json := pljson(w_rows.get(i));
                
                --nm_column := v_table.colunas.first;
                tmp := REMOVE_LINES(v_table.row);
                --3 = string, 4 = number, 5 = bool, 6 = null
                for j in 1..w_json.count loop
                    if w_json.get(j).get_type = 'string' then
                        popu(w_json.get(j).str, w_json.get(j).mapname);
                    elsif w_json.get(j).get_type = 'number' then
                        popu(w_json.get(j).num, w_json.get(j).mapname);
                    elsif w_json.get(j).get_type = 'bool' then
                        if w_json.get(j).get_bool then
                            popu('true', w_json.get(j).mapname);
                        else
                            popu('false', w_json.get(j).mapname);
                        end if;
                    elsif w_json.get(j).get_type = 'null' then
                        popu(w_json.get(j).get_null, w_json.get(j).mapname);
                    else
                        popu('', w_json.get(j).mapname);
                    end if;
                end loop;
                tmp2 := tmp2 || chr(10) || v_table.line || chr(10) || tmp;--REMOVE_LINES(v_table.row);
            end loop;
            
            if tmp2 is not null then
                return v_table.line||chr(10)||'| '||upper(p_nm_tabela)||chr(10)||v_table.line||v_table.head||chr(10)||tmp2||chr(10)||v_table.line; 
            else
                return null;
    --            return v_table.line||chr(10)||'| '||upper(p_nm_tabela)||v_table.line||v_table.head||v_table.line; 
            end if;
        end if;    
        
    end;
    
    --TODO
--    function get_show_table_on_console(p_sql varchar2, p_nm_tabela varchar2, all_columns boolean default true) return clob is
--    begin
--    
--    end;
    
    procedure show_console_table_example is
    
        v_table console_table;
        tmp clob;
        tmp2 clob;
        nm_column varchar2(1000);
        
        procedure popu(p_dado varchar2) is
        begin
            tmp := replace(tmp, nm_column, rpad(nvl(p_dado, ' '), v_table.colunas(nm_column).data_length, ' '));
        end;
        
    begin

        v_table := get_console_table('CANVAS_USUARIOS');

        for usuario in (select * from canvas_usuarios WHERE ROWNUM < 10) loop
            nm_column := v_table.colunas.first;
            tmp := REMOVE_LINES(v_table.row);
            while nm_column is not null loop
                if upper(nm_column) = 'FULL_NAME' then
                    popu(usuario.full_name);
                elsif nm_column = 'SHORT_NAME' then
                    popu(usuario.SHORT_NAME);
                elsif nm_column = 'SORTABLE_NAME' then
                    popu(usuario.SORTABLE_NAME);
                elsif nm_column = 'EMAIL' then
                    popu(usuario.EMAIL);
                elsif nm_column = 'LOGIN' then
                    popu(usuario.LOGIN);
                elsif nm_column = 'PASSWORD' then
                    popu(usuario.PASSWORD);
                elsif nm_column = 'SIS_USER_ID' then
                    popu(usuario.SIS_USER_ID);
                elsif nm_column = 'AUTH_PROVIDER_ID' then
                    popu(usuario.AUTH_PROVIDER_ID);
                elsif nm_column = 'DT_INCL' then
                    popu(usuario.DT_INCL);
                elsif nm_column = 'DT_UPDT' then
                    popu(usuario.DT_UPDT);
                elsif nm_column = 'CANVAS_ID' then
                    popu(usuario.CANVAS_ID);
                end if;
                nm_column := v_table.colunas.next(nm_column);
            end loop;
            tmp2 := tmp2 || v_table.line || chr(10) || tmp;
        end loop;
        
        plob(v_table.line||v_table.head||tmp2||v_table.line);
    end;

/*
================================================================================
                    Job Schedule service
================================================================================
*/

    procedure job_create(p_job_name varchar2, p_job_type varchar2, p_job_action varchar2, p_start_date varchar2, p_repeat_interval varchar2, p_end_date varchar2 default null, p_job_class varchar2 default 'DEFAULT_JOB_CLASS', p_comments varchar2 default null) is
        is_valid boolean;
    begin
        is_valid := false;
        if upper(p_job_type) in( 'PLSQL_BLOCK', 'STORED_PROCEDURE', 'EXECUTABLE', 'CHAIN', 'EXTERNAL_SCRIPT', 'SQL_SCRIPT', 'BACKUP_SCRIPT') then
            is_valid := true;
        end if;
        
        if is_valid then
            DBMS_SCHEDULER.CREATE_JOB (
            job_name           =>  p_job_name,
            job_type           =>  p_job_type,
            job_action         =>  p_job_action,
            start_date         =>  p_start_date,--to_char() --'28-APR-08 07.00.00 PM Australia/Sydney',
            repeat_interval    =>  p_repeat_interval, /* every other day */ /* FREQ=HOURLY;INTERVAL=2 every 2 hour*/
            end_date           =>  p_end_date,
            auto_drop          =>  FALSE,
            job_class          =>  p_job_class,
            comments           =>  p_comments);
        end if;
    end;
    
    procedure job_alter(p_nm_job varchar2, p_attribute varchar2, p_value varchar2) is begin
        SYS.DBMS_SCHEDULER.SET_ATTRIBUTE(p_nm_job, p_attribute, p_value);
    end;
    
    procedure job_stop(p_nm_job varchar2) is begin
        SYS.DBMS_SCHEDULER.STOP_JOB(job_name=>p_nm_job, force=>true);
    end;
    
    procedure job_enable(p_nm_job varchar2) is begin
        DBMS_SCHEDULER.ENABLE (p_nm_job);
    end;
    
    procedure job_disable(p_nm_job varchar2) is begin
        DBMS_SCHEDULER.DISABLE (p_nm_job);
    end;

    procedure job_run(p_nm_job varchar2) is begin
        DBMS_SCHEDULER.RUN_JOB(
        JOB_NAME            => p_nm_job,
        USE_CURRENT_SESSION => FALSE);
    end;
    
    procedure job_drop(p_nm_job varchar2) is begin
        DBMS_SCHEDULER.DROP_JOB (p_nm_job);
    end;
    
    procedure job_copy(p_old_job varchar2, p_new_job varchar2) is begin
        DBMS_SCHEDULER.COPY_JOB(p_old_job, p_new_job);
    end;
    
    function job_is_runnig(p_job_name in varchar2) return boolean is
        
--        cursor c_jobs(p_job_name in varchar2) is
--            select job_name, 
--                   session_id 
--              from dba_scheduler_running_jobs
--             where job_name = p_job_name;
             
--        v_job c_jobs%rowtype;
    begin
--        open c_jobs(p_job_name);
--        fetch c_jobs into v_job;
--        if c_jobs%found then
--            close c_jobs;
--            return true;
--        else
--            close c_jobs;
            return false;
--        end if;
    end;
    
/*
================================================================================
                    Util
================================================================================
*/
   
    FUNCTION VALIDA_CPF_CNPJ(V_CPF_CNPJ VARCHAR2) RETURN BOOLEAN IS
        
        TYPE ARRAY_DV IS VARRAY(2) OF PLS_INTEGER;
        
        V_ARRAY_DV      ARRAY_DV := ARRAY_DV(0, 0);
        CPF_DIGIT       CONSTANT PLS_INTEGER := 11;
        CNPJ_DIGIT      CONSTANT PLS_INTEGER := 14; 
        IS_CPF          BOOLEAN;
        IS_CNPJ         BOOLEAN;
        V_CPF_NUMBER    VARCHAR2(20);
        TOTAL           NUMBER := 0;
        COEFICIENTE     NUMBER := 0;
        DV1             NUMBER := 0;
        DV2             NUMBER := 0;
        DIGITO          NUMBER := 0;
        J               INTEGER;
        I               INTEGER;
    
    BEGIN
        IF V_CPF_CNPJ IS NULL THEN
            RETURN FALSE;
        END IF; 
        
        if V_CPF_CNPJ in ('00000000000', '11111111111', '22222222222', '33333333333', '44444444444', '55555555555', '66666666666', '77777777777', '88888888888', '99999999999') then
            return false;
        end if;
    
        /*
        Retira os caracteres não numéricos do CPF/CNPJ
        caso seja enviado para validação um valor com
        a máscara.
        */
    
        V_CPF_NUMBER := REGEXP_REPLACE(V_CPF_CNPJ, '[^0-9]'); 
    
        /*
        Verifica se o valor passado é um CPF através do
        número de dígitos informados. CPF = 11
        */
        
        IS_CPF := (LENGTH(V_CPF_NUMBER) = CPF_DIGIT); 
        
        /*
        Verifica se o valor passado é um CNPJ através do
        número de dígitos informados. CNPJ = 14
        */
        
        IS_CNPJ := (LENGTH(V_CPF_NUMBER) = CNPJ_DIGIT);
        
        IF (IS_CPF OR IS_CNPJ) THEN
            TOTAL := 0;
        ELSE
            RETURN FALSE;
        END IF;
    
        /*
        Armazena os valores de dígitos informados para
        posterior comparação com os dígitos verificadores calculados.
        */
        
        DV1 := TO_NUMBER(SUBSTR(V_CPF_NUMBER, LENGTH(V_CPF_NUMBER) - 1, 1));
        DV2 := TO_NUMBER(SUBSTR(V_CPF_NUMBER, LENGTH(V_CPF_NUMBER), 1)); 
        
        V_ARRAY_DV(1) := 0;
        V_ARRAY_DV(2) := 0; 
        
        /*
        Laço para cálculo dos dígitos verificadores.
        É utilizado módulo 11 conforme norma da Receita Federal.
        */
        
        FOR J IN 1 .. 2
        LOOP
            TOTAL := 0;
            COEFICIENTE := 2;
        
            FOR I IN REVERSE 1 .. ((LENGTH(V_CPF_NUMBER) - 3) + J)
            LOOP
                DIGITO := TO_NUMBER(SUBSTR(V_CPF_NUMBER, I, 1));
                TOTAL := TOTAL + (DIGITO * COEFICIENTE);   
                
                COEFICIENTE := COEFICIENTE + 1;
                IF (COEFICIENTE > 9) AND IS_CNPJ THEN
                COEFICIENTE := 2;
                END IF;   
        
            END LOOP; --for i
    
            V_ARRAY_DV(J) := 11 - MOD(TOTAL, 11);
            IF (V_ARRAY_DV(J) >= 10) THEN
                V_ARRAY_DV(J) := 0;
            END IF; 
        
        END LOOP; --for j in 1..2
    
        /*
        Compara os dígitos calculados com os informados para informar resultado.
        */
        
        RETURN(DV1 = V_ARRAY_DV(1)) AND(DV2 = V_ARRAY_DV(2)); 
        
    END VALIDA_CPF_CNPJ;
    
    procedure send_email(p_para varchar2 default 'wpiornedo@unifil.br', p_cc varchar2 default null, p_assunto varchar2, p_mensagem clob) is    
        wEMAIL EMAIL;
    begin
--        wEMAIL := new email('', 'dmorita@unifil.br', p_assunto, p_mensagem);
        if p_cc is not null then
            wEMAIL := NEW EMAIL(p_cc, p_para, p_assunto, p_mensagem);
        else
            wEMAIL := NEW EMAIL(p_para, p_assunto);
            wEMAIL.SET_MENSAGEM(p_mensagem);
        end if;
        
        if wEMAIL.enviar then null; end if;
    end;
    
    function get_terminal return varchar2 is begin return USERENV('terminal'); end;
    
    function get_user return varchar2 is
        CURSOR C_USR IS
            SELECT s.osuser
             FROM v$session s
            WHERE s.audsid = USERENV('sessionid');
        
        wOSUSER VARCHAR2(30);
    begin
        OPEN C_USR;
        FETCH C_USR INTO wOSUSER;
        if C_USR%notfound then
            wOSUSER   := 'NÃO ENCONTRADO';
        end if;
        CLOSE C_USR;
        
        return wOSUSER;
    end;

    function get_cep(p_nr_cep number) return r_cep is
    
        cursor c_cep(p_nr_cep number) is
            select gce.nr_cep         
                  ,gce.tp_logradouro
                  ,gce.nm_logradouro
                  ,gce.ds_complemento
                  ,gce.nm_bairro1 nm_bairro
                  ,gci.sg_uf
                  ,gci.nm_localidade
                  ,gci.sq_cidade
              from ger_ceps gce
                  ,ger_cidades gci
             where gce.sq_cidade = gci.sq_cidade
               and gce.nr_cep = p_nr_cep;
             
        wCEP r_cep;
    begin
        open c_cep(p_nr_cep);
        fetch c_cep into wCEP;
        close c_cep;
        
        return wCEP;
    end;
    
    
    function find_cep_by_webservice  (pNR_CEP in varchar2) return r_cep is

        type list_str is table of string_default; 
        
        urls list_str := list_str('http://api.postmon.com.br/v1/cep/x'
                                 ,'http://viacep.com.br/ws/x/json/');
        
        soap_respond   clob;
        wCEP           varchar2(8);
        v_os_user      varchar2(50);
        CEP            r_cep;
        ws_headers     webservice.r_headers;
        json_cep       pljson;
        dummy          binary_integer;
        
        cursor c_cep(p_nr_cep varchar2) is
            select 1
              from ger_ceps
             where nr_cep = p_nr_cep;
        
        cursor get_sq_cidade(p_nm_localidade varchar2) is
            select sq_cidade
              from ger_cidades
             where nm_localidade = upper(p_nm_localidade)
               AND rownum = 1;
            
        function try(p_url varchar2) return varchar2 is
        begin
            return webservice.call(replace(p_url, 'x', wCEP), headers => ws_headers);
        end;
        
        function get_value_from_json(p_nm_property varchar2, p_json_cep pljson) return varchar2 is
            v_value pljson_value;
        begin
            v_value := case when p_json_cep.exist(p_nm_property) then p_json_cep.get(p_nm_property) else p_json_cep.get(upper(p_nm_property)) end;
            if v_value is not null then
                if v_value.get_type = 'string' then
                    return v_value.get_string;
                elsif v_value.get_type = 'number' then
                    return to_char(v_value.get_number);
                elsif v_value.get_type = 'bool' then
                    if v_value.get_bool then
                        return 'true';
                    else
                        return 'false';
                    end if;
                else
                    return null;
                end if;  
            else
                return null;
            end if;
        end;
    
    begin
        --inicialize
        ws_headers('Content-Type') := 'text/json';
        wCEP := TO_CHAR(KEEP_NUMBER(pNR_CEP));
        
        --buscar nas APIs
        FOR i IN 1..urls.last LOOP
            BEGIN
                SOAP_RESPOND := TRY(urls(i));
--                plob('SOAP_RESPOND:'||SOAP_RESPOND);
                json_cep := pljson(SOAP_RESPOND);
                IF SOAP_RESPOND IS NOT NULL THEN
                    EXIT;
                END IF;
            EXCEPTION
                WHEN others THEN
                    P('Erro ao tentar pela URL ('||urls(i)||'), tentar com a próximo url caso exista');
                    SHOW_ERRO;
            END;
        END LOOP;
        
        --Popupalar r_cep e inserir cep caso não exista.
        IF json_cep IS NOT NULL THEN
            DECLARE
                v_tp_logradouro ger_ceps.tp_logradouro%TYPE;
                v_nm_logradouro ger_ceps.nm_logradouro%TYPE;
            BEGIN
                json_cep.PRINT;
                CEP.nr_cep          := TO_CHAR(KEEP_NUMBER(GET_VALUE_FROM_JSON('cep', json_cep)));
                CEP.nm_logradouro   := upper(CONVERT_UNICODE_TO_STRING(GET_VALUE_FROM_JSON('logradouro', json_cep)));
                v_tp_logradouro     := SUBSTR(CEP.nm_logradouro, 1, INSTR(CEP.nm_logradouro, ' '));
                v_nm_logradouro     := SUBSTR(CEP.nm_logradouro, INSTR(CEP.nm_logradouro, ' '), LENGTH(CEP.nm_logradouro));
                CEP.tp_logradouro   := upper(v_tp_logradouro);
                CEP.nm_logradouro   := upper(trim(v_nm_logradouro));
                CEP.ds_complemento  := upper(CONVERT_UNICODE_TO_STRING(GET_VALUE_FROM_JSON('complemento', json_cep)));
                CEP.nm_bairro       := upper(CONVERT_UNICODE_TO_STRING(GET_VALUE_FROM_JSON('bairro', json_cep)));
                CEP.sg_uf           := COALESCE(upper(GET_VALUE_FROM_JSON('estado', json_cep)), upper(GET_VALUE_FROM_JSON('uf', json_cep)));
                CEP.nm_localidade   := upper(CONVERT_UNICODE_TO_STRING(COALESCE(GET_VALUE_FROM_JSON('cidade', json_cep), GET_VALUE_FROM_JSON('localidade', json_cep))));
                
                OPEN get_sq_cidade(CEP.nm_localidade);
                FETCH get_sq_cidade INTO CEP.sq_cidade;
                CLOSE get_sq_cidade;
                
                OPEN c_cep(CEP.nr_cep);
                FETCH c_cep INTO dummy;
                
                IF c_cep%notfound THEN
                    P('Inserindo novo CEP - '||CEP.nr_cep);
                    INSERT 
                      INTO GER_CEPS 
                          (NR_CEP
                          ,TP_LOGRADOURO
                          ,NM_LOGRADOURO
                          ,DS_COMPLEMENTO
                          ,NM_BAIRRO1
                          ,SQ_CIDADE)
                   VALUES (CEP.nr_cep
                          ,CEP.tp_logradouro
                          ,CEP.nm_logradouro
                          ,CEP.ds_complemento
                          ,CEP.nm_bairro
                          ,CEP.sq_cidade);
                    
                    v_os_user := get_user; 
                    INSERT 
                      INTO GER_CEPS_LOG
                           (NR_CEP
                           ,NM_USUARIO
                           ,NM_LOGRADOURO
                           ,DS_COMPLEMENTO
                           ,TP_LOGRADOURO
                           ,NM_BAIRRO1
                           ,SQ_CIDADE
                           ,DS_LOG) 
                    VALUES (CEP.nr_cep
                           ,v_os_user
                           ,CEP.nm_LOGRADOURO
                           ,CEP.ds_COMPLEMENTO
                           ,CEP.TP_LOGRADOURO
                           ,CEP.nm_bairro
                           ,CEP.SQ_CIDADE
                           ,'INSERT BY UTIL.FIND_CEP_BY_WEBSERVICE CEP:'||CEP.nr_cep);
                END IF;
                CLOSE c_cep;
            END;
        END IF;
        v_os_user := get_user; 
        INSERT 
          INTO GER_CEPS_LOG
               (NR_CEP
               ,NM_USUARIO
               ,NM_LOGRADOURO
               ,DS_COMPLEMENTO
               ,TP_LOGRADOURO
               ,NM_BAIRRO1
               ,SQ_CIDADE
               ,DS_LOG) 
        VALUES (CEP.nr_cep
               ,v_os_user
               ,CEP.nm_LOGRADOURO
               ,CEP.ds_COMPLEMENTO
               ,CEP.TP_LOGRADOURO
               ,CEP.nm_bairro
               ,CEP.SQ_CIDADE
               ,'REALIZADA A BUSCA COM UTIL.FIND_CEP_BY_WEBSERVICE('||CEP.nr_cep||')');
        RETURN CEP;
    EXCEPTION 
        WHEN others THEN
            v_os_user := get_user; 
            INSERT 
              INTO GER_CEPS_LOG
                   (NR_CEP
                   ,NM_USUARIO
                   ,NM_LOGRADOURO
                   ,DS_COMPLEMENTO
                   ,TP_LOGRADOURO
                   ,NM_BAIRRO1
                   ,SQ_CIDADE
                   ,DS_LOG) 
            VALUES (CEP.nr_cep
                   ,v_os_user
                   ,CEP.nm_LOGRADOURO
                   ,CEP.ds_COMPLEMENTO
                   ,CEP.TP_LOGRADOURO
                   ,CEP.nm_bairro
                   ,CEP.SQ_CIDADE
                   ,'ERRO EM UTIL.FIND_CEP_BY_WEBSERVICE('||CEP.nr_cep||')'||CHR(10)||GET_ERRO);
            SHOW_ERRO;
            RAISE;
    END;
    
    procedure execute_hostcommand(p_script varchar2, p_action in varchar2, p_method in varchar2, p_json in clob default null, r_json out clob, r_msg out clob) is
        l_output  dbms_output.chararr;
        l_lines   integer := 1000000;
        l_tmp_lob clob;
        l_pl_json pljson;
        
        l_response_http varchar2(100);
        l_tmp_response clob;
            
        function eliminar_sujeira(t clob) return clob is
        begin
            --dbms_output.put_line('t==='||t);
            if t like 'Process out%' 
--            and t not like '%Erro%' 
            and t not like '%Sintaxe%'
            and t not like '%informado deve ser GET ou POSTthen%' 
            and t not like '%Runtime Error%' then
                
                l_tmp_response := replace(t, 'Process out :', '');
                
                if substr(l_tmp_response,1,1) = '{' then
                    return l_tmp_response; --replace(t, 'Process out :', '');
                elsif l_tmp_response like 'HTTP%' then
                    if l_response_http != '200' or l_response_http is null then
                        l_response_http := substr(l_tmp_response, instr(l_tmp_response, ' ') + 1, instr(l_tmp_response, ' ', -1) - (instr(l_tmp_response, ' ') + 1));
                    end if;
                end if;
            end if;
            return empty_clob();
        end;
        
        
    begin
        dbms_output.disable;
        dbms_output.enable(1000000);
        dbms_java.set_output(1000000);
        --host_command3('/home/oracle/integracaoCanvas,GET,users?page1');
        if p_json is null then
            host_command3(p_script||','||p_action||','||p_method);
        else--TRANSLATE (col_name, 'x'||CHR(10)||CHR(13), 'x')
            host_command3(p_script||','||p_action||','||p_method||',<json>'||replace(TRANSLATE(p_json,  'x'||chr(10)||chr(13), 'x'), 'null', '""')||'</json>');--p_json TODO
        end if;
        dbms_output.get_lines(l_output, l_lines);
        for i in 1 .. l_lines loop
            l_tmp_lob := eliminar_sujeira(l_output(i));
            util.p(l_output(i));
--            if g_is_debug then
--                dbms_output.put_line(UNISTR(l_output(i)));
--            end if;
            r_msg := r_msg || chr(10) ||l_output(i);
            if (l_tmp_lob != empty_clob()) then
                r_json := r_json || l_tmp_lob;
                --util.p('l_response_http::'||l_response_http);
                if l_response_http is not null then
                    l_pl_json := pljson(r_json);
                    l_pl_json.put('http_response', l_response_http);
                    --util.p(l_pl_json.to_char);
                    r_json := l_pl_json.to_char(false);
                end if;
            end if;
        end loop;
    end execute_hostcommand;
    
    function teste return varchar2 is
        w_marcaoes pljson;
        my_clob clob;
    begin
        w_marcaoes := new pljson('{"william": "nego do borel"}');
        my_clob := 'teste';
        return w_marcaoes.to_char;
    end;
END UTIL;
