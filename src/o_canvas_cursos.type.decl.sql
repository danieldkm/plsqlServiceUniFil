create or replace type o_canvas_cursos under o_canvas (
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
    * <p>Este pacote define o <em>PL/JSON</em>'s representa o objeto type do curso</p>
    *
    * <p> Este objeto representa a entidade Curso (Course) </p>
    * <strong>Exemplo:</strong>
    * <pre>
    * declare
    *   mycanvas o_canvas := o_canvas_cursos;
    *   cursoInserido pljson; 
    *   w_msg clob; 
    * begin
    *   cursoInserido := mycanvas.inserir(
    *   '{
    *       "course":
    *       {
    *           "account_id" : 1,
    *           "name":"Nombre del Curso",
    *           "code" : "C001",
    *           "end_at":"2017-01-07T02:59:00Z",
    *           "start_at":"2016-01-06T03:00:00Z",
    *           "restrict_to_dates": false,
    *           "sis_master_id":"30952006",
    *           "sis_term_id" : "term",
    *           "sis_course_id" :"30952006"
    *       },
    *       "publish": true,
    *       "import_content": true
    *   }', w_msg);
    *   cursoInserido.print;
    * end;
    * </pre>
    *
    * @headcom
    */

    /* Construtores */
    constructor function o_canvas_cursos return self as result,

    /* Requisições */
    /**
    * <p>Criar um Curso</p>
    * <p>Criar um curso individual e retorna a entidade atual criada.</p>
    *   
    * <p>
    *     <table>
    *         <thead>
    *             <tr>
    *                 <td>Campo</td>
    *                 <td>Tipo</td>
    *                 <td>Comentários</td>
    *             </tr>
    *         </thead>
    *         <tbody>
    *             <tr><td>account_id          </td><td>integer     </td><td>ID de conta / subconta no LMS.</td></tr>
    *             <tr><td>name                </td><td>string      </td><td>Nome do curso</td></tr>
    *             <tr><td>code                </td><td>string      </td><td>Código do curso.</td></tr>
    *             <tr><td>start_at            </td><td>datetime    </td><td>(opcional) Data de início do curso.</td></tr>
    *             <tr><td>end_at              </td><td>datetime    </td><td>(opcional) Data de fim do curso.</td></tr>
    *             <tr><td>restrict_to_dates   </td><td>boolean     </td><td>(opcional) Restringe inscrições nas datas de início e fim do curso. Se este parâmetro não vier definido, assumirá o valor padrão false. Se vier definido como true, será necessário definir as datas de início e fim do curso.</td></tr>
    *             <tr><td>sis_master_id       </td><td>string      </td><td>Id conteúdo do curso mestre. O curso será criado somente quando a referência de sis_master_id for válida.</td></tr>
    *             <tr><td>sis_term_id         </td><td>string      </td><td>Identificador do período acadêmico.</td></tr>
    *             <tr><td>sis_course_id       </td><td>string      </td><td>Identificador do curso.</td></tr>
    *             <tr><td>publish             </td><td>boolean     </td><td>Determina se o curso deve estar publicado ou não.</td></tr>
    *             <tr><td>import_content      </td><td>boolean     </td><td>Determina se o conteúdo do curso master será importado. Para isso acontecer, este parâmetro deve ser definido como true e sis_master_id deverá ter um ID válido.</td></tr>
    *         </tbody>
    *     </table>
    * </p>
    *     
    * <p>
    *     <code>
    *         curl -X POST -H "Authorization: Bearer <Bearer>" -H "Content-Type: application/json"
    *         -d 
    *         '{
    *             "course":
    *             {
    *                 "account_id" : 1,
    *                 "name":"Nombre del Curso",
    *                 "code" : "C001",
    *                 "end_at":"2017-01-07T02:59:00Z",
    *                 "start_at":"2016-01-06T03:00:00Z",
    *                 "restrict_to_dates": false,
    *                 "sis_master_id":"30952006",
    *                 "sis_term_id" : "term",
    *                 "sis_course_id" :"30952006"
    *             },
    *             "publish": true,
    *             "import_content": true
    *         }'
    *         "https://<apim host and port>/<university>/api/lms/v1/courses"
    *     </code>
    * </p>
    * @param  p_json  json a ser enviado.
    * @param  r_msg   log.
    * 
    * @return resposta da requisição.
    *  
    */
    member function inserir_cursos(SELF IN OUT NOCOPY o_canvas_cursos, p_json clob    , r_msg out clob) return pljson,
    member function inserir       (SELF IN OUT NOCOPY o_canvas_cursos, p_json varchar2, r_msg out clob) return pljson,
    member function atualizar     (SELF IN OUT NOCOPY o_canvas_cursos, p_json varchar2, r_msg out clob) return pljson,

    /* Buscas */
    /**
        Listar Cursos
        Lista todos os cursos criados anteriormente dentro da conta. Este serviço é paginado.

        Campo       Tipo    Comentários
        account_id  integer (opcional) ID de conta / sub-conta onde você deseja listar os cursos. Se o parâmetro não é enviado, por padrão, a conta root é assumida.
        state       string  (opcional) Você pode usar o Estado para filtrar os cursos. Os valores permitidos são: created, claimed, available, completed, deleted, all. Se o parâmetro não for recebido, tendo em conta todos os estados, exceto deleted.
        search_term string  (opcional) Sequência de caracteres ( pelo menos 3), para ser usado como dados de pesquisa padrão no nome do curso, código do curso ou SIS_ID.
        include     string  (opcional) Você pode usar o valor total_students para que a informação iria ser adicionado ao número de alunos do estado: active e invited.
        sis_term_id string  (opcional) O SIS_ID de um período acadêmico pode ser usado para filtrar os cursos. Se o parâmetro não for recebido, todos os períodos são considerados.

    curl -X GET -H "Authorization: Bearer <bearer>" -H "Content-Type: application/json" 
    "https://<apim host and port>/<university>/api/lms/v1/
    courses?account_id=<account_id>&state=<state>&search_term=<search_term>&include=<include>&sis_term_id=<sis_term_id>"


    */
    member function find_all(SELF IN OUT NOCOPY o_canvas_cursos, p_account_id number default null, p_state varchar2 default null, p_search_term varchar2 default null, p_include varchar2 default null, p_sis_term_id varchar2 default null, r_log out clob) return pljson_list,

    /* Atividades - Assignments */
    /**
    * <p>Listar atividades de um curso.</p>
    * <p>Listar as atividades e tarefas de um curso.</p>
    * <p>courses/<sis_course_id>/assignments?search_term=<search_term>&only_gradable_assignments=<only_gradable_assignments></p>
    * 
    * @param  p_sis_course_id             (requerido) ID interno do SIS acadêmico que referencia o curso de onde se encontram as atividades.
    * @param  p_search_term               (opcional) Cadeia de caracteres (pelo menos 3), que será usada como um padrão de pesquisa nos dados do nome da atividade.
    * @param  p_only_gradable_assignments (opcional) Se for true, determina que a lista deve trazer apenas as atividades qualificáveis. Por padrão, o valor é false.
    * @param  show_log                    (opcional) exibir log.
    * 
    * @return lista de json.
    */
    member function find_assignments_by_id(SELF IN OUT NOCOPY o_canvas_cursos, p_sis_course_id varchar2, p_search_term varchar2 default null, p_only_gradable_assignments boolean default false, r_msg out clob) return pljson_list,

    /* Seções */
    /**
    * <p>Listar seções em um Curso.</p>
    * <p>Lista todas as seções previamente criadas dentro de um curso. Este serviço é paginado.</p>
    * <p>courses/sis_course_id:<sis_course_id>/sections?include=<include></p>
    * 
    * @param  p_sis_course_id             (requerido) ID interno do sistema acadêmico (SIS) atribuído ao curso.
    * @param  p_include                   (opcional) Você pode usar o valor total_students para que a informação seja adicionada do número de alunos do estado: active e invited.
    * @param  show_log                    (opcional) exibir log.
    *
    * @return lista de json.
    */
    member function find_sections_by_id   (SELF IN OUT NOCOPY o_canvas_cursos, p_sis_course_id varchar2, p_include varchar2 default null, r_msg out clob) return pljson_list,

    /* Inscrições */
    /**
    * <p>Listar inscrições em um Curso.</p>
    * <p>Lista todas as inscrições previamente criadas dentro de um curso. Este serviço é paginado.</p>
    * <p>courses/sis_course_id:<sis_course_id>/enrollments?role=<role>&state=<state></p>
    * 
    * @param  p_sis_course_id (requerido) ID interno do sistema acadêmico (SIS) atribuído ao curso.
    * @param  p_role          (opcional) Nome do role específico para o qual deseja para filtrar.
    * @param  p_state         (opcional) Estado das inscrições a serem recuperadas. Se este parâmetro for omitido, as inscrições no estado active e invited, são consideradas. Valores suportados: active, invited, creation_pending, deleted, rejected, completed, inactive.
    * @param  r_msg           (requerido) log.
    * 
    * @return lista de json.
    */
    member function find_enrollments_by_id(SELF IN OUT NOCOPY o_canvas_cursos, p_sis_course_id varchar2, p_role varchar2 default null, p_state varchar2 default null, r_msg out clob) return pljson_list,
    
    /* Cursos Modelo (BluePrint Courses) */
    /**
    * <p>Obter informação do Curso Modelo.</p>
    * <p>Provê a informação sobre o curso modelo especificado.</p>
    * <p>courses/sis_course_id:<sis_course_id>/blueprint/template_id:<template_id></p>
    * 
    * @param  p_sis_course_id (requerido) ID interno do SIS que referencia o curso modelo.
    * @param  p_template_id   (requerido) Atualmente temos somente o modelo default, porém no futuro pode ser que tenhamos outro conteúdo para esse parâmetro.
    * @param  r_msg           (requerido) log.
    * 
    * @return lista de json.
    */
    member function find_blueprint_by_id          (SELF IN OUT NOCOPY o_canvas_cursos, p_sis_course_id varchar2, p_template_id varchar2 default 'default', r_msg out clob) return pljson_list,

    /**
    * <p>Obter informação do curso associado.</p>
    * <p>Provê informação sobre os cursos associados a um curso modelo.</p>
    * <p>courses/sis_course_id:<sis_course_id>/blueprint/template_id:<template_id>/associated_courses</p>
    *     
    * @param  p_sis_course_id (requerido) ID interno do SIS que referencia o curso modelo.
    * @param  p_template_id   (requerido) Atualmente temos somente o modelo default, porém no futuro pode ser que tenhamos outro conteúdo para esse parâmetro.
    * @param  r_msg           (requerido) log.
    * 
    * @return lista de json.
    */
    member function find_blueprint_associate_by_id(SELF IN OUT NOCOPY o_canvas_cursos, p_sis_course_id varchar2, p_template_id varchar2 default 'default', r_msg out clob) return pljson_list,

    /**
    * <p>Lista de modelos de migração.</p>
    * <p>Mostra uma lista paginada de migrações para o modelo.</p>
    * <p>courses/sis_course_id:<sis_course_id>/blueprint/template_id:<template_id>/migrate</p>
    * 
    * @param  p_sis_course_id (requerido) ID interno do SIS que referencia o curso modelo.
    * @param  p_template_id   (requerido) Atualmente temos somente o modelo default, porém no futuro pode ser que tenhamos outro conteúdo para esse parâmetro.
    * @param  r_msg           (requerido) log.
    * 
    * @return lista de json.
    */
    member function find_blueprint_migrate_by_id  (SELF IN OUT NOCOPY o_canvas_cursos, p_sis_course_id varchar2, p_template_id varchar2 default 'default', r_msg out clob) return pljson_list,

    /**
    * <p>Mostrar migração de um curso modelo.</p>
    * <p>Mostra o estado de uma migração.</p>
    * <p>courses/sis_course_id:<sis_course_id>/blueprint/template_id:<template_id>/migrate/migration_id:<migration_id></p>
    * 
    * @param  p_sis_course_id (requerido) ID interno do SIS que referencia o curso modelo.
    * @param  p_template_id   (requerido) Atualmente temos somente o modelo default, porém no futuro pode ser que tenhamos outro conteúdo para esse parâmetro.
    * @param  p_migration_id  (requerido) ID interno da migração.
    * @param  r_msg           (requerido) log.
    * 
    * @return lista de json.
    */
    member function find_bp_migration_by_id       (SELF IN OUT NOCOPY o_canvas_cursos, p_sis_course_id varchar2, p_template_id varchar2 default 'default', p_migration_id varchar2, r_msg out clob) return pljson_list,

    /**
    * <p>Obter detalhes de uma migração.</p>
    * <p>Mostra as alterações que foram propagadas numa migração de um curso modelo.</p>
    * <p>courses/sis_course_id:<sis_course_id>/blueprint/template_id:<template_id>/migrate/migration_id:<migration_id>/details</p>
    * 
    * @param  p_sis_course_id (requerido) ID interno do SIS que referencia o curso modelo.
    * @param  p_template_id   (requerido) Atualmente temos somente o modelo default, porém no futuro pode ser que tenhamos outro conteúdo para esse parâmetro.
    * @param  p_migration_id  (requerido) ID interno da migração.
    * @param  r_msg           (requerido) log.
    * 
    * @return lista de json.
    */
    member function find_bp_migration_detail_by_id(SELF IN OUT NOCOPY o_canvas_cursos, p_sis_course_id varchar2, p_template_id varchar2 default 'default', p_migration_id varchar2, r_msg out clob) return pljson_list,

    /**
    * <p>Listar importações de um curso modelo.</p>
    * <p>Mostra uma lista de migrações de um curso modelo importadas em um curso associado.</p>
    * <p>courses/sis_course_id:<sis_course_id>/blueprint/subscription_id:<subscription_id>/migrate</p>
    * 
    * @param  p_sis_course_id   (requerido) ID interno do SIS que referencia o curso modelo.
    * @param  p_subscription_id (requerido) ID interno da subscrição do modelo associado do curso. Valor por padrão é default.
    * @param  r_msg             (requerido) log.
    * 
    * @return lista de json.
    */
    member function find_bp_subscription_by_id    (SELF IN OUT NOCOPY o_canvas_cursos, p_sis_course_id varchar2, p_subscription_id varchar2 default 'default', r_msg out clob) return pljson_list,
    /* Conjuntos de Grupos */
    /**
    * <p>Listar conjuntos de grupos de um curso.</p>
    * <p>Devolve uma lista de conjuntos de grupos de um curso.</p>
    * 
    * <p>courses/sis_course_id:<sis_course_id>/group_categories</p>
    * 
    * @param  p_sis_course_id   (requerido) ID interno do SIS que referencia o curso modelo.
    * @param  r_msg             (requerido) log.
    * 
    * @return lista de json.
    */
    member function find_group_by_id(SELF IN OUT NOCOPY o_canvas_cursos, p_sis_course_id varchar2, r_msg out clob) return pljson_list,

    /**
    * <p>Criar um conjunto de grupos.</p>
    * <p>Criar um novo conjunto de grupos.</p>
    * 
    * <p>courses/sis_course_id:<sis_course_id>/group_categories</p>
    * 
    * <p>
    *     <code>
    *         {
    *             "name" : "GRUPO SECCION", --(requerido) Nome do conjunto de grupos.
    *             "create_group_count" : 4, --Quantidade máxima de usuários por grupo. Se é null, não existe um limite.
    *             "group_limit": null       --Quantidade de grupos para criar. Não é mapeado se não é enviado ou enviado como null.
    *         }'
    *     </code>
    * </p>
    * 
    * @param  p_json            (requerido) json do grupo.
    * @param  p_sis_course_id   (requerido) ID interno do SIS que referencia o curso modelo.
    * @param  r_msg             (requerido) log.
    * 
    * @return lista de json.
    */
    member function create_group    (SELF IN OUT NOCOPY o_canvas_cursos, p_json varchar2, p_sis_course_id varchar2, r_msg out clob) return pljson,

    /* Controles */
    /**
    * <p>Foi criado esse controle pois o controle padrão
    * (controle_save_request) não atende a estrutura do curso.</p>
    * 
    * @param  p_sql       select a ser enviado.
    * @param  is_batch    em lote.
    * @param  p_verify_id verifica se o id ja existe no canvas.
    * @param  r_msg       <b>retorna</b> o log.
    */
    member procedure controller(p_sql in varchar2, is_batch in boolean, p_verify_id in boolean, r_msg out clob)
)NOT FINAL
/
sho err