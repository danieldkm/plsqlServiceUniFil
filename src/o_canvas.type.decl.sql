set define off
create or replace type o_canvas as object (

    /*
    Copyright (c) 2018 Daniel Keyti Morita

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
    */

    /**
    * <p>Este pacote define o <em>PL/JSON</em>'s representa o objeto type principal do canvas</p>
    *
    *
    * <strong>Examplo:</strong>
    * <pre>
    * declare
    *   mycanvas o_canvas := o_canvas;
    * begin
    *   mycanvas.find_all.print();
    *   mycanvas.find_by_id('ID da Entidade').print();
    * end;
    * </pre>
    *
    * @headcom
    */
    
    /* Variáveis */
    entidade  varchar2(100),
    script    varchar2(100),
    metodo    varchar2(100),
    acao      varchar2(100),
    show_log  varchar2(10),
    variables pljson,
    
    /* Construtores */

    /**
    * <p>Construtor para criar objeto vazio.</p>
    *
    *
    * @return A instância <code>pljson</code>.
    */
    constructor function o_canvas return self as result,

    /**
    * <p>Construtor <code>pljson</code> instância defindo o nome da entidade.</p>
    *
    *
    * @param pnm_entidade O nome da entidade que ira definir a variável <code>entidade</code>.
    * @return A instância <code>pljson</code>.
    */
    constructor function o_canvas(pnm_entidade varchar2) return self as result,
    
    /* GETs and SETs */
    member procedure set_entidade(p_entidade varchar2),
    member procedure set_script  (p_script   varchar2),
    member procedure set_metodo  (p_metodo   varchar2),
    member procedure set_acao    (p_acao     varchar2),
    member procedure set_show_log(p_show_log varchar2),
    member procedure set_variables(p_variables pljson),
    member procedure set_default(SELF IN OUT NOCOPY o_canvas),
    
    member function get_entidade return varchar2,
    member function get_script(SELF IN OUT NOCOPY o_canvas)   return varchar2,
    member function get_metodo    return varchar2,
    member function get_acao      return varchar2,
    member function get_show_log  return boolean,
    member function get_variables return pljson,

    /* CRUD */
    member function inserir_em_lote(SELF IN OUT NOCOPY o_canvas, p_json clob, r_msg out clob) return pljson,
    member function inserir (SELF IN OUT NOCOPY o_canvas, p_json varchar2, r_msg out clob) return pljson,
    member function atualizar (SELF IN OUT NOCOPY o_canvas, p_id varchar2, p_json varchar2, r_msg out clob) return pljson,
    member function deletar  (SELF IN OUT NOCOPY o_canvas, p_id varchar2, r_msg out clob) return pljson,
    /* Requisições */
    /**
    * <p>Executar comandos OS via JAVA <code>(Host_command3)</code>, 
    * nesse caso foi criado um arquivo 'BASH' que está definido na variável <code>script</code> 
    * que define o caminho do arquivo e o nome do mesmo e retorna o resultado.</p>
    * 
    * @param  p_action    ação a ser requisitado (GET, POST, PUT, etc)
    * @param  p_method    metodo da chamada da requisição
    * @param  p_json      quando há persistência deve informar
    * @param  r_json      <b>retorna</b> o resultado da requisição, ler documentação para mais detalhes
    * @param  r_msg       <b>retorna</b> as informações para o log
    */
    member procedure execute_hostcommand(SELF IN OUT NOCOPY o_canvas, p_action in varchar2, p_method in varchar2, p_json in clob default null, r_json out clob, r_msg out clob),
    
    /**
    * Padronizar a chamada das requisições.
    *     
    * @param  p_json          json a ser enviado
    * @param  p_action        tipo da requisição
    * @param  p_ds_chamada    descrição da chamada "INSERT"/"UPDATE"
    * @param  show_log        exibir log
    * 
    * @return resposta da requisição.
    */
    member function call_request(SELF IN OUT NOCOPY o_canvas, p_json varchar2, p_ds_chamada varchar2, r_msg out clob) return pljson,

    
    /**
    * Request GET
    * 
    * @param  p_metodo        metodo a ser realizado na busca
    * @param  p_ds_chamada    descrição da chamada
    * @param  r_json          resposta da requisição
    * @param  r_log           log
    */
    member procedure request_get(SELF IN OUT NOCOPY o_canvas, p_metodo varchar2, p_ds_chamada varchar2, r_json out clob, r_log out clob),

    /**
    * Request POST/PUT
    * 
    * @param  p_json          json a set enviado.
    * @param  p_metodo        metodo a ser realizado na busca
    * @param  p_ds_chamada    descrição da chamada
    * @param  r_json          resposta da requisição
    * @param  r_log           log
    */
    member procedure request(SELF IN OUT NOCOPY o_canvas, p_json varchar2, p_action varchar2, p_metodo varchar2, p_ds_chamada varchar2, r_json out clob, r_log out clob),
    

    /* Buscas */
    /**
        Request GET, busca por metodo
        
        @param  p_metodo        metodo a ser utilizado
        @param  p_ds_chamada    descrição da chamada
        @param  has_pagination  caso tenha paginação realizar as chamadas com "paginadas"
        @param  show_log        exibir log
        
        @return lista de json
    */
    member function find_by_method(SELF IN OUT NOCOPY o_canvas, p_metodo varchar2, p_ds_chamada varchar2, has_pagination boolean default false, r_msg out clob) return pljson_list,

    /**
    * Request GET, busca todos os dados conforme entidade.
    *
    * @param  r_msg        log.
    * 
    * @return lista de json.
    */
    member function find_all(SELF IN OUT NOCOPY o_canvas, r_msg out clob) return pljson_list,

    /**
    * Request GET, busca dados pelo id.
    * 
    * @param  p_id    id da entidade.
    * @param  r_msg   log.
    * 
    * @return resposta, lista de json.
    */
    member function find_by_id(SELF IN OUT NOCOPY o_canvas, p_id varchar2, r_msg out clob) return pljson,


    /* Controles */
    /**
    * Objetivo: tratar o formato do json para enviar na requisição.
    * 
    * @param  p_pljson        json a ser configurado.
    * @param  p_entity        nome da entidade.
    * @param  p_template      template como referência. 
    * @param  validate_json   validar json caso true.
    * 
    * @return string do json tratado.
    * @throws e_formato_json_invalido msg_formato_json_invalido.
    */
    member function controller_prepare_json(p_pljson pljson, p_entity in varchar2, p_template varchar2, validate_json boolean, r_msg out clob) return varchar2,

    /**
    * Padronizar a forma de salvar/criar/enviar uma chamada de
    * requisição.
    * <b>Procedimento:</b>
    * <p>log_footer: log de rodapé</p>
    * 
    * @param  p_sql           select a ser enviado.
    * @param  p_method        metodo a ser utilizado na  chamada.
    * @param  p_ds_entity     descrição da entidade a ser chamada (Usuário, Curso,...).
    * @param  p_entity        nome da entidade (user, course, term, etc).
    * @param  p_nm_table      nome da tabela que será atualizada no base oracle.
    * @param  p_template      template padrão referente da entidade.
    * @param  is_batch        em lote.
    * @param  p_verify_id     verifica se o id ja existe no canvas.     
    * @param  p_method_find   metodo de busca para buscar o id no canvas.
    * @param  r_msg           <b>retorna</b> o log.
    *
    */
    member procedure controller_save_request(p_sql in varchar2, p_method in varchar2, p_ds_entity in varchar2, p_entity in varchar2, p_nm_table in varchar2, p_template in varchar2, is_batch in boolean, p_verify_id in boolean,r_msg out clob, p_method_find varchar2 default '?&search_term=', is_update boolean default true)
    
)not final;
/
sho err