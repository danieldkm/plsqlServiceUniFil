create or replace type o_canvas_usuarios under o_canvas (
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
    * <p>Este pacote define o <em>PL/JSON</em>'s representa o objeto type do usuário</p>
    *
    * <p> Este objeto representa a entidade Usuário (User) </p>
    * <strong>Exemplo:</strong>
    * <pre>
    * declare
    *   mycanvas o_canvas := o_canvas_usuarios;
    *   usuarioInserido pljson; 
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
    *   usuarioInserido.print;
    * end;
    * </pre>
    *
    * @headcom
    */

    constructor function o_canvas_usuarios return self as result,
    
    /**
    * <p>Criar Usuários</p>
    * <p>Criar um grupo de usuários e não retorna informações dentro do corpo da resposta. Criação é diferido e os valores resultantes podem ser consumida pela fila correspondente ou de retorno de chamada.</p>
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
    *             <tr><td>full_name           </td><td>string</td><td>Nome completo.</td></tr>
    *             <tr><td>short_name          </td><td>string</td><td>Nome será exibido em fóruns, mensagens e Comentários.</td></tr>
    *             <tr><td>sortable_name       </td><td>string</td><td>Nome para a função de classificação.</td></tr>
    *             <tr><td>email               </td><td>string</td><td>Endereço de e-mail.</td></tr>
    *             <tr><td>login               </td><td>string</td><td>(requerido) Identificador de entrada.</td></tr>
    *             <tr><td>password            </td><td>string</td><td>Senha.</td></tr>
    *             <tr><td>sis_user_id         </td><td>string</td><td>Identificador do usuário dentro do sistema acadêmico.</td></tr>
    *             <tr><td>auth_provider_id    </td><td>string</td><td>(opcional) Provedor de autenticação associado ao login.</td></tr>
    *         </tbody>
    *     </table>
    * </p>
    * <p>
    *     <code>
    *         curl -X POST -H "Authorization: Bearer <Bearer>" -H "Content-Type: application/json"
    *         -d '[
    *                 {
    *                     "user": {
    *                         "full_name": "Juan Perez",
    *                         "short_name" : "Juan",
    *                         "sortable_name" : "Juan Perez",
    *                         "email": "juan.perez@noreply.com",
    *                         "login": "juan.perez",
    *                         "password" : "this is the password",
    *                         "sis_user_id": "sis00001",
    *                         "auth_provider_id": ""
    *                     }
    *                 },
    *                 {
    *                     "user": {
    *                         "full_name": "Juan Martinez",
    *                         "short_name" : "Juan",
    *                         "sortable_name" : "Juan Martinez",
    *                         "email": "juan.martinez@noreply.com",
    *                         "login": "juan.martinez",
    *                         "password" : "this is the password",
    *                         "sis_user_id": "sis00002",
    *                         "auth_provider_id": ""
    *                     }
    *                 }
    *         ]'
    *         "https://<apim host and port>/<university>/api/lms/v1/users/create"
    *     </code>
    * </p>
    * 
    * @param  p_json  json a ser enviado;
    * @param  r_msg   log.
    * @return resposta da requisição.
    * 
    */
    member function inserir_usuarios(SELF IN OUT NOCOPY o_canvas_usuarios, p_json clob    , r_msg out clob) return pljson,

    /**
    * <p>Criar um usuário</p>
    * <p>Criar um usuário individual e retorna a entidade de usuário criada.</p>
    * 
    * <p>
    *     <table>
    *         <thead>
    *         <tr>
    *             <td>Campo</td>
    *             <td>Tipo</td>
    *             <td>Comentários</td>
    *         </tr>
    *             <tr><td>full_name           </td><td>string  </td><td>Nome completo.</td></tr>
    *             <tr><td>short_name          </td><td>string  </td><td>Nome será exibido em fóruns, mensagens e Comentários.</td></tr>
    *             <tr><td>sortable_name       </td><td>string  </td><td>Nome para a função de classificação.</td></tr>
    *             <tr><td>email               </td><td>string  </td><td>Endereço de e-mail.</td></tr>
    *             <tr><td>login               </td><td>string  </td><td>(requerido) Identificador de entrada.</td></tr>
    *             <tr><td>password            </td><td>string  </td><td>Senha.</td></tr>
    *             <tr><td>sis_user_id         </td><td>string  </td><td>Identificador do usuário dentro do sistema acadêmico.</td></tr>
    *             <tr><td>auth_provider_id    </td><td>string  </td><td>(opcional) Provedor de autenticação associado ao login.</td></tr>
    *         </thead>
    *     </table>
    * </p>
    * 
    * <p>
    *     <code>
    *         curl -X POST -H "Authorization: Bearer <Bearer>" -H "Content-Type: application/json"
    *         -d '{
    *             "user": {
    *                 "full_name": "Juan Perez",
    *                 "short_name" : "Juan",
    *                 "sortable_name" : "Juan Perez",
    *                 "email": "juan.perez@noreply.com",
    *                 "login": "juan.perez",
    *                 "password" : "this is the password",
    *                 "sis_user_id": "sis00001",
    *                 "auth_provider_id": ""
    *             }
    *         }'
    *         "https://<apim host and port>/<university>/api/lms/v1/users"
    *     </code>
    * </p>
    * 
    * @param  p_json  json a ser inserido.
    * @param  r_msg   log.
    * @return reposta da requisição.
    * 
    */
    member function inserir         (SELF IN OUT NOCOPY o_canvas_usuarios, p_json varchar2, r_msg out clob) return pljson,

    /**
    * <p>Atualizar Usuário</p>
    * <p>Atualiza os dados do usuário.</p>
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
    *             <tr><td>user_id         </td><td>string  </td><td>(requerido) ID identificador do usuário no LMS. (CANVAS_ID)</td></tr>
    *             <tr><td>full_name       </td><td>string  </td><td>(opcional) Nome completo.</td></tr>
    *             <tr><td>short_name      </td><td>string  </td><td>(opcional) O nome que será exibido em fóruns, mensagens e Comentários.</td></tr>
    *             <tr><td>sortable_name   </td><td>string  </td><td>(opcional) Nome para a função de classificação.</td></tr>
    *             <tr><td>email           </td><td>string  </td><td>(opcional) Endereço de e-mail.</td></tr>
    *             <tr><td>login           </td><td>string  </td><td>Identificador de entreda. (Requerido se você precisa para atualizar senha ou sis_user_id)</td></tr>
    *             <tr><td>password        </td><td>string  </td><td>(opcional) Senha.</td></tr>
    *             <tr><td>sis_user_id     </td><td>string  </td><td>(opcional) Identificador do usuário dentro do sistema acadêmico.</td></tr>
    *         </tbody>
    *     </table>
    * </p>
    * 
    * <p>
    *     <code>
    *         curl -X PUT -H "Authorization: Bearer <Bearer>" -H "Content-Type: application/json"
    *         -d 
    *         '{
    *             "user": {
    *                 "full_name": "Juan Perez",
    *                 "short_name" : "Juan",
    *                 "sortable_name" : "Juan Perez",
    *                 "email": "juan.perez@noreply.com"
    *                 "login": "juan.perez",
    *                 "password" : "this is the password",
    *                 "sis_user_id": "sis00001"
    *             }
    *         }'
    *         "https://<apim host and port>/<university>/api/lms/v1/users/<user_id>"
    *     </code>
    * </p>
    * 
    * @param  p_json  json a ser inserido.
    * @param  r_msg   log.
    * @return reposta da requisição.
    * 
    */
    member function atualizar       (SELF IN OUT NOCOPY o_canvas_usuarios, p_json varchar2, p_user_id varchar2, r_msg out clob) return pljson,


    /**
    * <p>Unir um usuário com outro.</p>
    * <p>Unificar dois usuários em um só. Remove usuário identificado pelo from_user_id e mover todos os dados para o usuário identificado por to_user_id.</p>
    * 
    * <p>users/<from_user_id>/merge_into/<to_user_id></p>
    * 
    * @param  p_from_user_id  (requerido) ID do usuário a ser excluído.
    * @param  p_to_user_id    (requerido) ID do usuário que conterá os dados e login de ambos usuários.
    * @param  r_msg           (requerido) log.
    * 
    * @return resposta da requisição.
    */
    member function unir            (SELF IN OUT NOCOPY o_canvas_usuarios, p_from_user_id varchar2, p_to_user_id varchar2, r_msg out clob) return pljson,


    /**
    * <p>Obter o progresso de um usuário em um curso.</p>
    * <p>Devolve a informação relativa ao progresso de um usuário em um curso determinado.</p>
    * 
    * <p>users/<user_id>/progress?sis_course_id=<sis_course_id></p>
    * 
    * @param  user_id         (requerido) ID identificador do usuario no LMS. (canvas_id)
    * @param  p_sis_user_id   (requerido) ID identificador do curso no SIS.
    * @param  r_msg           (requerido) log.
    * 
    * @return resposta.
    */
    member function find_progress_by_id(SELF IN OUT NOCOPY o_canvas_usuarios, user_id varchar2, p_sis_user_id varchar2, r_msg out clob) return pljson_list,

    /**
        <p>Listar Usuários</p>
        <p>Listar todos os usuários criados anteriormente dentro da conta. Este serviço é paginado.</p>

        <p>
            <table>
                <thead>
                    <tr>
                        <td>Campo</td>
                        <td>Tipo</td>
                        <td>Comentários</td>
                    </tr>
                </thead>
                <tbody>
                    <tr><td>account_id 1*</td>  <td>integer</td> <td>(opcional) ID da conta / sub - conta onde você quer para listar os usuários. Se o parâmetro não é enviado, por padrão, a conta root é assumido.</td></tr>
                    <tr><td>search_term 2*</td> <td>string</td>  <td>(opcional) Sequência de caracteres (pelo menos 3), para ser utilizado como padrão de busca em SIS_ID dados, nome, login_id ou e-mail.</td></tr>
                </tbody>
            </table>
        </p>
        
        <p>
            <code>
                curl -X GET -H "Authorization: Bearer <bearer>" -H "Content-Type: application/json"
                "https://<apim host and port>/<university>/api/lms/v1/
                users?account_id=<account_id>&search_term=<search_term>"
            </code>
        </p>

        @param  p_account_id    1*
        @param  p_search_term   2*
        @param  r_log           log.
        @return reposta da requisição de busca.
    */
    member function find_all           (SELF IN OUT NOCOPY o_canvas_usuarios, p_account_id number default null, p_search_term varchar2 default null, r_log out clob) return pljson_list
)NOT FINAL
/
sho err