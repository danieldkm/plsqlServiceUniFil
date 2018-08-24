create or replace package         canvas is

/**
========================================================================<br/>
<h2>
    Projeto: Integração Canvas
</h2>
<p>
    As funções de scripts devem ser executadas antes de executar o envio
    dos jsons, para atualizar ou inserir nas tabelas.<br/>
    O Pacote está estruturado em camadas para facilitar a manutenção e
    atualizações futuras;
</p>
<p>
    Visões -> Controles -> Serviços -> Controle de Persistencia
</p>
<p>
    Exemplo:
    <pre>
        view_usr_salvar
        ---->controller_save_usr --trata a resposta
        -------->controller_save_request --Retorna a resposta
        -------->service_update_table_usr -- Após tratar resposta caso não retorne erro
        ------------>daos
        ---------------->Chamadas do HostCommand de requisição.
    </pre>
</p>
<p>
    <h3>
        As funções utils podem ser utilizadas em todas as camadas, caso necessário.
    </h3>
</p>
<p>
    <i>**Uso das TYPES Objects para JSON**</i><br/>
    Todo <i>json</i> é transformado em tipos de objetos, que podem ser objeto <i>json</i>,
    <i>json_value</i> e/ou <i>json_list</i> seguindo a estrutura dele.
    É possivel transformar uma string <i>json</i> em objeto ou <i>sql</i> (select),
    caso seja um <i>select</i> ele irá transformar em </i>json_list</i>, irá depender
    do formado passado, caso seja uma lista será um <i>json_list</i>.
    <p>Este projeto utiliza esses objetos para manipular, adequar e/ou validar
    o <i>json</i> que o usuário deseja criar.</p>
</p>
<pre>
    1. JSON
    2. JSON_LIST
    3. JSON_VALUE
</pre>
<p>
    Foi utilizado para cada entidade um template específico, onde valida o
    formato do json, além disso verifica quais campos são obrigatorios ou 
    quais são opcionais e por fim quais são chaves e quais campos devem ser
    removidos para o envio.
</p>
<pre>
1. (opcional)  - não realiza nenhuma validação.
2. (requerido) - comparar o atributo requerido com o template
3. (remover)   - remove antes de enviar para o Canvas
4. (chave)     - utilizado na hora de atualizar, indicando como condições (where ?)
5. (atualizar) - utilizado na hora de atualizar a tabela na base oracle (set ?)
</pre>
<h3>Determina o tipo de dados a serem extraidos/atualizados</h3>
<p>
    Substituir o valor correspodente a cada tipo definido no atributo do template;
    <pre>
        a. &lt;type:date&gt;
        b. &lt;type:number&gt;
        c. &lt;type:string&gt;
    </pre>
</p>
<h3> Diagrama's </h3>
<h4> Casos de uso </h4>  
<pre>
- Controle de usuários
- Controle de Periodo Academico
- Controle de Cursos
- Controle de Seções (turmas)
- Controle de Inscrições
</pre>
 
<table border="1">
    <tr align="center">
        <th colspan="4" > HISTÓRICO DE ALTERAÇÃO </th>
    <tr>
    <tr align="center">
        <th> Data </th>
        <th> Autor </th>
        <th> Versão </th>
        <th align="left">alteração?</th>
    </tr>
    <tr align="center">
        <td> 19/09/2017 </td>
        <td> dmorita </td>
        <td> 0.0.01 </td>
        <td align="left"> criação da package </td>
    </tr>
    <tr align="center">
        <td> 19/10/2017 </td>
        <td> dmorita </td>
        <td> 0.1.02 </td>
        <td align="left"> Foi adicionado no template mais uma opção para manipular/extrair informações importantes para a chamada da requisição e/ou atualizações das tabelas; </td>
    </tr>
    <tr align="center">
        <td> 20/10/2017 </td>
        <td> dmorita </td>
        <td> 0.0.03 </td>
        <td align="left"> 
        Foi criada duas funções para manipular
        as opções dos templates, para mais
        detalhes verificar na propria função.
        </td>
    </tr>
</table>

<table border="1">
    <tr align="center">
        <th colspan="4" > DETALHES DE ALTERAÇÃO </th>
    <tr>
    <tr align="center">
        <th> Data </th>
        <th> Descrição </th>
    </tr>
    <tr align="center">
        <td> 19/10/2017 </td>
        <td align="left">
            <h4>Novos tipos de variaveis permitidos</h4>
            <ul>
                <li>a. &lt;type:date&gt; --date por enquanto está substituindo para sysdate</li>
                <li>b. &lt;type:number&gt; </li>
                <li>c. &lt;type:string&gt; </li>
            </ul>
        </td>
    </tr>
    <tr align="center">
        <td> 20/10/2017 </td>
        <td align="left">
            <h4>Novos procedimentos</h4>
            <ul>
                <li>util_extract_from_template</li>   
                <li>util_remove_property</li>
            </ul>
        </td>
    <tr>
</table>

@headcom
*/
    /* templates */
/**
    Atributo de templates
*/
    json_template_user varchar2(1000) := 
    '{'||
        '"USER": {'||
            '"FULL_NAME": "(requerido) Nome completo.",'||
            '"SHORT_NAME" : "(opcional) Nome será exibido em fóruns, mensagens e comentários.",'||
            '"SORTABLE_NAME" : "(opcional) Nome para a função de classificação.",'||
            '"EMAIL": "(requerido) Endereço de e-mail.",'||
            '"LOGIN": "(requerido) Identificador de entrada.",'||
            '"PASSWORD" : "(requerido) Senha.",'||
            '"SIS_USER_ID": "(requerido) (chave) Identificador do usuário dentro do sistema acadêmico.",'||
            '"AUTH_PROVIDER_ID": "(opcional) Provedor de autenticação associado ao login.",'||
            '"DT_INCL": "(opcional) (atualizar) (remover) <type:date>",'||
            '"CANVAS_ID": "(opcional) (atualizar) (remover) <type:string>"'||
        '}'||
    '}';
    
    json_template_updt_user varchar2(1000) := 
    '{'||
        '"USER": {'||
            '"USER_ID": "(requerido) (remover) ",'||
            '"FULL_NAME": "(opcional) Nome completo.",'||
            '"SHORT_NAME" : "(opcional) O nome que será exibido em fóruns, mensagens e comentários.",'||
            '"SORTABLE_NAME" : "(opcional) Nome para a função de classificação.",'||
            '"EMAIL": "(opcional) Endereço de e-mail.",'||
            '"LOGIN": "(requerido) Identificador de entreda. (Requerido se você precisa para atualizar senha ou sis_user_id)",'||
            '"PASSWORD" : "(opcional) Senha.",'||
            '"SIS_USER_ID": "(opcional) (chave) Identificador do usuário dentro do sistema acadêmico.",'||
            '"DT_UPDT": "(opcional) (atualizar) (remover) <type:date>"'||
        '}'||
    '}';

                          
    json_template_users varchar2(1000) := '{'||
                                              '['||
                                                '"user": {'||
                                                  '"full_name": "Juan Perez",'||
                                                  '"short_name": "Juan",'||
                                                  '"sortable_name": "Juan Perez",'||
                                                  '"email": "juan.perez@noreply.com",'||
                                                  '"login": "juan.perez",'||
                                                  '"password": "this is the password",'||
                                                  '"sis_user_id": "sis00001",'||
                                                  '"auth_provider_id": ""'||
                                                '},'||
                                                '"user": {'||
                                                  '"full_name": "Juan Martinez",'||
                                                  '"short_name": "Juan",'||
                                                  '"sortable_name": "Juan Martinez",'||
                                                  '"email": "juan.martinez@noreply.com",'||
                                                  '"login": "juan.martinez",'||
                                                  '"password": "this is the password",'||
                                                  '"sis_user_id": "sis00002",'||
                                                  '"auth_provider_id": ""'||
                                                '}'||
                                              ']'||
                                            '}';
                                            
    json_template_course varchar2(2000) := 
    '{'||
        '"COURSE": {'||
                    '"ACCOUNT_ID": "(requerido) ID de conta / subconta no LMS.",'||
                    '"NAME": "(requerido) Nome do curso",'||
                    '"CODE": "(requerido) Código do curso.",'||
                    '"END_AT": "(opcional) Data de fim do curso.",'||
                    '"START_AT": "(opcional) Data de início.do curso.",'||
                    '"RESTRICT_TO_DATES": "(opcional) Restringe inscrições nas datas de início e fim do curso. Se este parâmetro não é padrão assume false.",'||
                    '"SIS_MASTER_ID": "(requerido) Id conteúdo do curso mestre.",'||
                    '"SIS_TERM_ID": "(requerido) (chave) Identificador do período acadêmico.",'||
                    '"SIS_COURSE_ID": "(requerido) (chave) Identificador do curso.",'||
                    '"DT_INCL": "(opcional) (atualizar) (remover) <type:date>",'||
                    '"CANVAS_ID": "(opcional) (atualizar) (remover) <type:string>"'||
                  '},'||
        '"PUBLISH": "(requerido) Determina se o curso deve estar publicado ou não.",'||
        '"IMPORT_CONTENT": "(requerido) Determina se o conteúdo do curso master será importado. Para isso a acontecer este parâmetro deve ser definido para true y sis_master_id ter um ID válido."'||
    '}';                  
    json_template_updt_course varchar2(2000) := 
    '{'||
        '"COURSE": {'||
                '"ACCOUNT_ID": "(opcional) ID de conta / sub - conta no LMS onde o curso deve estar.",'||
                '"NAME": "(opcional) Nome do curso.",'||
                '"CODE": "(opcional) Código do curso.",'||
                '"START_AT": "(opcional) Data de início do curso.",'||
                '"END_AT": "(opcional) Data de fim do curso.",'||
                '"RESTRICT_TO_DATES": "(opcional) Quando é true, restrito aos participantes do curso pelo início e no final do curso.",'||
                '"SIS_TERM_ID": "(opcional) ID Interna de período acadêmico SIS para o qual o curso está associado.",'||
                '"SIS_COURSE_ID": "(opcional) (chave) Novo ID interno do SIS que identificará o curso.",'||
                '"OLD_SIS_COURSE_ID": "(requerido) (remover) ID SIS interno que identifica o curso existente.",'||
                '"EVENT": "(opcional) Abaixo os valores permitidos:'||
                                    ' offer: Publicar o curso'||
                                    ' claim: Remove a publicação do curso, somente se os alunos não possuem nenhuma nota.'||
                                    ' conclude: Concluir o curso. Ele não permite novas inscrições e o curso permanece como consulta.'||
                                    ' delete: Apaga o curso e inscrições.'||
                                    ' undelete: Tenta recuperar um curso excluído, mas não é garantido ser restaurado. Se puder ser'||
                                    ' restaurado o curso vai aparecer como novo e as inscrições não são recuperadas.",'||
                '"DT_UPDT": "(opcional) (atualizar) (remover) <type:date>"'||
        '}'||
    '}';
    
    json_template_elim_course varchar2(2000) := 
    '{'||
        '"SIS_COURSE_ID": "(requerido) (chave) Identificador do curso.",'||
        '"DT_UPDT": "(opcional) (atualizar) (remover) <type:date>"'||
    '}';
    
    json_template_term varchar2(1000) := 
    '{'||
        '"TERM": {'||
            '"NAME": "(requerido)",'||
            '"SIS_TERM_ID": "(requerido) (chave)",'||
            '"START_AT": "(opcional)",'||
            '"END_AT": "(opcional)",'||
            '"STUDENT_START_AT": "(opcional)",'||
            '"STUDENT_END_AT": "(opcional)",'||
            '"TEACHER_START_AT": "(opcional)",'||
            '"TEACHER_END_AT": "(opcional)",'||
            '"ASSISTANT_START_AT": "(opcional)",'||
            '"ASSISTANT_END_AT": "(opcional)",'||
            '"DESIGNER_START_AT": "(opcional)",'||
            '"DESIGNER_END_AT": "(opcional)",'||
            '"ACCOUNT_ID": "(opcional)",'||
            '"DT_INCL": "(opcional) (atualizar) (remover) <type:date>",'||
            '"CANVAS_ID": "(opcional) (atualizar) (remover) <type:string>"'||
        '}'||
    '}';
    
    json_template_updt_term varchar2(2000) := 
    '{'||
        '"TERM": {'||
            '"NAME": "(requerido) Nome completo.",'||
            '"OLD_SIS_TERM_ID": "(requerido)(remover) ID interno do sistema acadêmico (SIS) atribuído ao período acadêmico.",'||
            '"SIS_TERM_ID": "(requerido) (chave) Novo ID interno del sistema acadêmico (SIS) atribuído ao período acadêmico.",'||
            '"START_AT": "(opcional) Data de início do período acadêmico.",'||
            '"END_AT": "(opcional) Data de fim do período acadêmico.",'||
            '"STUDENT_START_AT": "(opcional) Data de inicio para os estudantes no nível do período acadêmico.",'||
            '"STUDENT_END_AT": "(opcional) Data de fim para os estudantes no nível do período acadêmico.",'||
            '"TEACHER_START_AT": "(opcional) Data de inicio para os professores no nível do período acadêmico.",'||
            '"TEACHER_END_AT": "(opcional) Data de fim para os professores no nível do período acadêmico.",'||
            '"ASSISTANT_START_AT": "(opcional) Data de inicio para os professores assistentes no nível do período acadêmico.",'||
            '"ASSISTANT_END_AT": "(opcional) Data de fim para os professores assistentes no nível do período acadêmico.",'||
            '"DESIGNER_START_AT": "(opcional) Data de inicio para os designers no nível do período acadêmico.",'||
            '"DESIGNER_END_AT": "(opcional) Data de fim para os designers no nível do período acadêmico.",'||
            '"ACCOUNT_ID": "(opcional) ID da conta de onde pretende para atualizar o período acadêmico. Se o parâmetro não é enviado, por padrão, a conta root é assumido.",'||
            '"DT_UPDT": "(opcional) (atualizar) (remover) <type:date>"'||
        '}'||
    '}';
    
    json_template_find_term varchar2(2000) := 
    '{'||
        '"STATE": "(opcional) Valores permitidos: active, deleted, all",'||
        '"INCLUDE": "(opcional) Se o valor permitido é enviado, em seguida, os detalhes das datas de cada tipo de papel traz. Valor permitido: overrides",'||
    '}';
    
    json_template_section varchar2(1000) := 
    '{'||
        '"COURSE_SECTION": {'||
            '"SIS_COURSE_ID": "(requerido) Código do curso no sistema acadêmico.",'||
            '"NAME": "(requerido) Nome da seção.",'||
            '"END_AT": "(opcional) Data de fim da seção",'||
            '"START_AT": "(opcional) Data de início da seção",'||
            '"SIS_SECTION_ID": "(requerido) (chave) Código da seção no sistema acadêmico.",'||
            '"ISOLATE_SECTION": "(requerido) Indicador para permitir o isolamento de seções.",'||
            '"RESTRICT_TO_DATES": "(opcional) Restringe as inscrições as datas de inicio e fim da seção. Se este parâmetro não é enviado, por padrão assume false.",'||
            '"DT_INCL": "(opcional) (atualizar) (remover) <type:date>",'||
            '"CANVAS_ID": "(opcional) (atualizar) (remover) <type:string>",'||
            '"GROUP_ID": "(opcional) (atualizar) (remover) <type:number>"'||
        '}'||
    '}';
    
    json_template_updt_section varchar2(1000) := 
    '{'||
        '"COURSE_SECTION": {'||
            '"OLD_SIS_SECTION_ID": "(requerido)(remover) Código do sistema acadêmico para a seção que pretende atualizar.",'||
            '"NAME": "(opcional) Novo nome da seção.",'||
            '"SIS_SECTION_ID": "(opcional) (chave) Novo código do sistema acadêmico para a seção.",'||
            '"START_AT": "(opcional) Nova data de inicio da seção.",'||
            '"END_AT": "(opcional) Nova data de fim da seção.",'||
            '"RESTRICT_TO_DATES": "(opcional) Restringe inscrições para as datas de início e de fim da seção.",'||
            '"DT_UPDT": "(opcional) (atualizar) (remover) <type:date>"'||
        '}'||
    '}';
    
    json_template_elim_section varchar2(1000) := 
    '{'||
        '"SIS_SECTION_ID": "(requerido) (chave)",'||
        '"DT_EXCL": "(opcional) (atualizar) (remover) <type:date>"'||
    '}';
    
    
    json_template_enrollment varchar2(2000) :=
    '{'||
        '"ENROLLMENT": {'||
            '"USER_ID": "(requerido) ID do usuário a ser inscrito.",'||
            '"SIS_USER_ID": "(chave) (remover) CPF do usuário a ser inscrito.",'|| --campo onde é necessário para realizar a atualização da inscrição
            '"ENROLLMENT_ID": "(requerido) (remover)",'||
            '"TYPE": "(chave) (requerido) Tipo de Inscrição. Os valores possíveis: StudentEnrollment, TeacherEnrollment, TaEnrollment, ObserverEnrollment, DesignerEnrollment",'||
            '"ROLE_ID": "(opcional) Identificador do role personalizado atribuído a um usuário.",'||
            '"SIS_SECTION_ID": "(chave) (requerido) (remover) ID interno do sistema acadêmico atribuído à seção.",'||
            '"STATE": "(requerido) Estado da inscrição. Valores possíveis: active, invited, inactive",'||
            '"LIMIT_INTERACTION": "(requerido) true: Limita a interação somente entre os participantes da seção.",'||
            '"SEND_NOTIFICATION": "(opcional) Indicador se deve enviar notificações ao usuário.",'||
            '"GROUP_ID": "(opcional) Identificador do grupo ao qual deseja inscrever. Se não utiliza o group_id poderá não ser enviado como parte do body ou estar presente e vazio.",'||
            '"DT_INCL": "(opcional) (atualizar) (remover) <type:date>",'||
            '"CANVAS_ID": "(opcional) (atualizar) (remover) <type:string>"'||
        '}'||
    '}';
    
    json_template_del_enrollment varchar2(1000) := 
    '{'||
        '"SIS_COURSE_ID": "(requerido) ID interno do SIS que referencia o cursos onde se encontra e inscrição.",'||
        '"ENROLLMENT_ID": "(requerido) ID do sistema LMS que identifica a inscrição.",'||
        '"ACTION": "(requerido) Tarefa a realizar: conclude, delete ou deactivate",'||
        '"SIS_USER_ID": "(chave) para updt",'||
        '"SIS_SECTION_ID": "(chave) para updt",'||
        '"CANVAS_ID": "(chave) para updt",'||
        '"DT_UPDT": "(opcional) (atualizar) (remover) <type:date>",'||
        '"STATE": "(opcional) (atualizar) (remover) <type:string>"'||
    '}';
    
    json_template_updt_enrollment varchar2(1000) := 
    '{'||
        '"SIS_COURSE_ID": "(requerido) (remover) ID interno do SIS que referencia o curso onde se encontra a inscrição.",'||
        '"ENROLLMENT_ID": "(requerido) (remover) ID do sistema LMS que identifica a inscrição.",'||
        '"SIS_USER_ID": "(chave)(remover) para updt",'||
        '"SIS_SECTION_ID": "(chave)(remover) para updt",'||
        '"CANVAS_ID": "(chave)(remover) para updt",'||
        '"DT_UPDT": "(opcional) (atualizar) (remover) <type:date>",'||
        '"STATE": "(opcional) (atualizar) (remover) <type:string>"'||
    '}';
    
    json_tmpt_detail_enrollment varchar2(1000) :=
    '{'||
        '"ACCOUNT_ID": "(remover) (opcional) ID da conta/subconta onde pesquisar a inscrição. Se o parâmetro não é enviado, a conta principal (valor = 1) é assumida.",'||
        '"ENROLLMENT_ID": "(requerido) A identificação interna atribuída a inscrição."'||
    '}';
    
    json_find_by_user_enrollment varchar2(1000) :=
    '{'||
        '"SIS_USER_ID": "(requerido) ID interno do sistema acadêmico (SIS) atribuído ao usuário.",'||
        '"ROLE": "(opcional) Nome do role específico para o qual deseja para filtrar.",'||
        '"STATE": "(opcional) Estado das inscrições a serem recuperadas. Se este parâmetro for omitido, as inscrições no estado active e invited, são consideradas. Valores suportados: active, invited, creation_pending, deleted, rejected, completed, inactive."'||
    '}';
    
    json_temp_updt_table_course varchar2(1000) :=
    '{'||
        '"SIS_COURSE_ID": "(chave)(requerido) ID interno do sistema acadêmico (SIS) atribuído ao curso.",'||
        '"CANVAS_ID": "(opcional)(atualizar) para updt.",'||
        '"DT_INCL": "(opcional) (atualizar) (remover) <type:date>"'||
    '}';
    
    json_temp_updt_table_enroll varchar2(1000) :=
    '{'||
        '"SIS_USER_ID": "(chave)(requerido) ID interno do sistema acadêmico (SIS) atribuído ao usuário.",'||
        '"ROLE_ID": "(opcional)(chave) para updt.",'||
        '"SIS_SECTION_ID": "(opcional)(chave) para updt.",'||
        '"CANVAS_ID": "(opcional)(atualizar) para updt.",'||
        '"ROLE": "(opcional) Nome do role específico para o qual deseja para filtrar.",'||
        '"DT_UPDT": "(opcional) (atualizar) (remover) <type:date>",'||
        '"STATE": "(opcional) (atualizar) (remover) <type:string>"'||
    '}';
    
    json_template_link_group varchar2(1000) := 
    '{'||
        '"GROUP_ID": "(requerido) (remover) ID interno do grupo.",'||
        '"SIS_USER_ID": "(requerido) (remover) ID interno do SIS que referencia o usuário.",'||
        '"USER_ID": "(requerido) <SIS_USER_ID>:AAA"'||
    '}';
    
    --Exceções
    e_formato_json_invalido exception;
    e_id_not_found          exception;
    e_id_canvas_not_found   exception;
    e_batch_not_found       exception;
    e_table_not_update      exception;
    e_not_update            exception;
    e_not_deleted           exception;
    e_no_tag_found          exception;
    msg_e_formato_json_invalido varchar2(100) := 'Inicio Error: Formato inválido; '                   ||chr(10)||'dado'||chr(10)||'Fim error;';
    msg_e_id_not_found          varchar2(100) := 'Inicio Error: Id não encontrado;'                   ||chr(10)||'dado'||chr(10)||'Fim error;';
    msg_e_id_canvas_not_found   varchar2(100) := 'Inicio Error: Id (Canvas_id) não encontrado;'       ||chr(10)||'dado'||chr(10)||'Fim error;';
    msg_e_batch_not_found       varchar2(100) := 'Inicio Error: Requisição em Lote não encontrada;'   ||chr(10)||'dado'||chr(10)||'Fim error;';
    msg_e_table_not_update      varchar2(100) := 'Inicio: Foi atualizado 0 registro;'                 ||chr(10)||'dado'||chr(10)||'Fim;';
    msg_e_not_update            varchar2(100) := 'Inicio Error: Não atualizou no canvas;'             ||chr(10)||'dado'||chr(10)||'Fim error;';
    msg_e_not_deleted           varchar2(100) := 'Inicio Error: Não deletou no canvas;'               ||chr(10)||'dado'||chr(10)||'Fim error;';
    msg_e_no_tag_found          varchar2(100) := 'Inicio Error: Não encontrou o valor da tag no json;'||chr(10)||'dado'||chr(10)||'Fim error;';
    
    --Exceções de curso
    e_curso_not_update            exception;
    msg_e_curso_not_update        varchar2(100) := 'Inicio Erro: Tabela canvas_cursos não atualizado;'||chr(10)||'dado'||chr(10)||'Fim erro;';
    
    --Types
    type r_periodo_academico is record (canvas_id number
                                       ,sis_term_id varchar2(200)
                                       ,name varchar2(200)
                                       ,start_at date
                                       ,end_at date
                                       ,state varchar2(50)
                                       ,student_start_at date
                                       ,student_end_at date
                                       ,teacher_start_at date
                                       ,teacher_end_at date
                                       ,assistant_start_at date
                                       ,assistant_end_at date
                                       ,designer_start_at date
                                       ,designer_end_at date);
                                       
    type r_periodos_academico is table of r_periodo_academico index by binary_integer;

    type r_usuario is record (canvas_id varchar2(100)
                             ,full_name varchar2(200)
                             ,short_name varchar2(100)
                             ,sortable_name varchar2(200)
                             ,login_id varchar2(200)
                             ,sis_user_id varchar2(200)
                             ,email varchar2(200)
                             ,last_login varchar2(200));

--    type r_usuarios is table of r_usuario index by binary_integer;
    type r_usuarios is table of canvas_usuarios%rowtype index by binary_integer;
    
    type r_curso is record (canvas_id varchar2(100)
                             ,sis_course_id varchar2(200)
                             ,name varchar2(100)
                             ,code varchar2(200)
                             ,status varchar2(200)
                             ,account_id varchar2(200)
                             ,start_at varchar2(50)
                             ,end_at varchar2(50));
--    type r_cursos is table of canvas_cursos%rowtype index by binary_integer;
    type r_cursos is table of r_curso index by binary_integer;

    type r_secao is record (canvas_id number
                           ,sis_section_id varchar2(200)
                           ,name varchar2(100)
                           ,code varchar2(200)
                           ,course_id number
                           ,status varchar2(200)
                           ,account_id varchar2(200)
                           ,start_at date
                           ,end_at date);
    type r_secoes is table of r_secao index by binary_integer;
    
    type r_valor is record (atributo  varchar2(100)
                           ,valor     varchar2(1000)
                           ,isErro    boolean);

    --Type arrays
    type r_valores   is table of r_valor    index by binary_integer;
    type r_r_valores is table of r_valores  index by binary_integer;
    type r_dados     is table of r_valor    index by varchar2(100);
    type r_r_dados   is table of r_dados    index by binary_integer;
    procedure execute_hostcommand(p_action in varchar2, p_method in varchar2, p_json in clob default null, r_json out clob, r_msg out clob);
    --GET's and SET's
    function  get_status_academico(pnr_matricula varchar2, pnr_ano_semestre varchar2, pid_curso number, pid_turma varchar2, pst_academico varchar2) return varchar2;
    
    --procedure execute_hostcommand(p_action in varchar2, p_method in varchar2, p_json in clob default null, r_json out clob, r_msg out clob);
    
    --Academico
/**
    <p>Retorna todos os períodos academicos.</p>
    @param  exibir_json se true então exibie no console
    @return r_periodos_academico
*/
    function view_all_aca(exibir_json boolean default false) return r_periodos_academico;
/**
    <p>Envia requisição para salvar todos os períodos academico listados no select ou json.</p>
    <p>Caso seja json segui a seguinte estrutura:
    <code>
        select *
          from canvas_log
         where nm_table = ''
    </code>
    </p>
    @param  exibir_json se true então exibie no console
    @return r_periodos_academico
*/
    procedure view_aca_salvar(p_sql varchar2, r_msg out clob, is_batch boolean default false, p_verify_id boolean default false);
    procedure view_aca_atualizar(p_sql varchar2, r_msg out clob);
    --Usuários
    function view_all_usrs(exibir_json boolean default false) return r_usuarios;
    function view_usr_by_id(p_sis_user_id varchar2,exibir_json boolean default false) return canvas_usuarios%rowtype;
    procedure view_usr_salvar(p_sql varchar2, r_msg out clob, is_batch boolean default false, p_verify_id boolean default false);
    --Cursos
    procedure view_crs_salvar(p_sql varchar2, r_msg out clob, is_batch boolean default false, p_verify_id boolean default false);
    function view_all_crs(exibir_json boolean default false) return r_cursos;
    procedure alerta_curso;
    --Seções
    function view_all_scs(p_sis_course_id varchar2, exibir_json boolean default false) return r_secoes;
    procedure view_scs_salvar(p_sql varchar2, r_msg out clob, is_batch boolean default false, p_verify_id boolean default false);
    procedure view_scs_atualizar(p_sql varchar2, r_msg out clob);
    procedure view_scs_liberar_eliminar(p_sql varchar2, r_msg out clob);
    
    --Inscricções
    procedure view_ins_detalhes(p_sql varchar2, r_msg out clob);
    procedure view_ins_reativar(p_sql varchar2, r_msg out clob);
    procedure view_ins_update_table(p_sql varchar2, r_msg out clob);
    
/**
    <p>
        Reatualiza as inscrições para reenviar novamente, este procedimento será 
        utilizado quando os usuários que tem permissões de exclusão, excluir o 
        grupo ¬¬.
    </p>
    <p>
        O metodo se baseia na id da seção (<b>@p_sis_section_id</b>) para atualizar o 
        grupo id (<b>@p_group_id</b>) do mesmo, após realizar a atualização do grupo 
        devemos atualizar todas as inscrições dessa seção, onde devemos setar nulo 
        nos campos data de atualização (<em>dt_updt</em>) e id do canvas (<em>canvas_id</em>),
        feito isso será reenviado na rotina de inserção das inscrições. Por fim a 
        função está gravando no canvas_log, a operação e dados que foram atualizados, 
        para localizar utilize o nome do metodo como "<em>CANVAS.VIEW_INS_REENVIO</em>",
        ou ainda pelas tabelas "<em>CANVAS_SECOES</em>" e "<em>CANVAS_INSCRICOES</em>".
    </p>
    <p>
        Exemplos:
        <ul>
            <li>
                Bloco
                <code>
                    begin
                        canvas.view_ins_reenvio('STGT4006.GAST301K.20181',309 , true);
                    end;
                </code>
            </li>
            <li>
                Select log
                <code>
                    select * 
                      from canvas_log 
                     where nm_metodo = 'CANVAS.VIEW_INS_REENVIO'
                       and nm_table = 'CANVAS_SECOES'
                       --and nm_table = 'CANVAS_INSCRICOES'
                     order by dt_incl desc
                </code>
            </li>
        </ul>
    </p> 
    
    @param  p_sis_section_id    id da seção.
    @param  p_group_id          id do grupo.
    @param  show_table          (opcional) caso queira ver os dados que foram atualizados.
     
*/
    procedure view_ins_reenvio(p_sis_section_id in varchar2, p_group_id number, show_table boolean default false);
  
/**
    <p>
        Verificar se o usuário foi enviado nas inscrições, para isso
        utilizo o parâmetro <b>@p_sis_user_id</b> para identificar.
    </p>
    
    @param  p_sis_user_id   id do usuário
    @return   se existir retorna 1 senão 0
*/
    function view_ins_user_exists(p_sis_user_id varchar2) return binary_integer;
/**
    <p>
        Realiza a inserção/atualização da nota das inscrições por seção.
    </p>
    @param  p_sis_section_id    seção a ser buscada para trazer as inscrições com a nota.
    @param  r_msg               retorna log.
    @param  save_log            caso queira salvar o log da rotina.
*/
    procedure view_ins_salvar_nota(p_sis_section_id varchar2, r_msg out clob, save_log boolean default true);
    
/**
    <p>
        Realiza deleção da inscrição.
    </p>
    @param  p_sql               lista de inscrições a serem "deletados".
    @param  r_msg               retorna log..
*/
    procedure view_ins_deletar(p_sql varchar2, r_msg out clob);
    
    --Grupos
    function view_grp_by_curso(p_sis_course_id varchar2, exibir_json boolean default false) return clob;
    function view_grp_by_subconta(p_account_id varchar2, exibir_json boolean default false) return clob;
    function view_grp_by_category(p_account_id varchar2, exibir_json boolean default false) return clob;
    --Teste
--    function get_result(p_resposta_js clob) return r_valores;
--    function get_valores(p_resposta_js clob) return r_r_valores;
--    function get_users(p_json_usuarios clob) return r_usuarios;
--    function dao_find_all(p_metodo varchar2, p_parametros varchar2 default null) return clob;
--    function service_validate_json(p_template varchar2, p_validate varchar2, p_validate_value boolean default false) return boolean;
--    function util_all_atribute_to_lower(p_json clob) return clob;
    
    --convertendo em json
--    function util_list_to_json(p_json_template varchar2,p_json_list json_list, p_type varchar2) return clob;
    
    procedure executar_script;
    procedure executar_integracao;
    procedure executar_inscricao;
    procedure executar_notas;
    procedure executar_inscricao_updt_table;
    procedure executar_periodo_academico;
    procedure executar_curso_updt_table;
    procedure executar_curso;
    procedure executar_secao;
    procedure executar_usuario;
    procedure executar_vincular_grupo;
    
    procedure util_insert_log(p_msg clob, p_nm_table varchar2, p_nm_metodo varchar2);
    function util_remove_empty_column(p_json pljson) return pljson;
    function util_validate_json(p_template varchar2, p_validate varchar2, p_validate_value boolean default false) return boolean;

    --functions of job
    procedure stop_job;
/**
    <p>
        Rotina ativa o agendamento, para iniciar o JOB
    </p>
    <p>
        <code>
    begin
        canvas.enabled_job;
    end;
        </code>
    <p>
*/
    procedure enabled_job;
    procedure disable_job;
    procedure running_job;
end canvas;
/

create or replace package body         canvas is
    -- constants
    script varchar2(100) := '/home/oracle/integracaoCanvas'; --TEST => integracaoCanvas.test --Produção => integracaoCanvas
    
    keep_words varchar2(100) := '.@_';
    is_debug boolean := true;
    
    
    function get_courses(p_json clob) return r_cursos;
    /****************************Inicio Script*********************************/
    PROCEDURE SCRIPT_CRIAR_PERIODO_ACADEMICO(pID_CURSO NUMBER, pID_TURMA varchar2, pNR_ANO_SEMESTRE varchar2) IS
    BEGIN

        /*insere periodos academico*/
        INSERT INTO CANVAS_PERIODOS_ACADEMICO
            SELECT distinct CPER.NAME           
                  ,CPER.SIS_TERM_ID    
                  ,CPER.START_AT       
                  ,CPER.END_AT         
                  ,CPER.NR_ANO_SEMESTRE
                  ,CPER.TP_ORIGEM      
                  ,CPER.TP_REGIME      
                  ,NULL DT_INCL        
                  ,SYSDATE DT_UPDT
                  ,NULL CANVAS_ID        
              FROM CANVAS_PERIODO_ACADEMICO_V CPER
            WHERE (ID_CURSO = pID_CURSO or pID_CURSO is null)
              and (id_turma = pid_turma or pid_turma is null)
              and (nr_ano_semestre = pnr_ano_semestre or pnr_ano_semestre is null)
              AND NOT EXISTS (SELECT 1
                                FROM CANVAS_PERIODOS_ACADEMICO CPER1
                               WHERE CPER1.SIS_TERM_ID = CPER.SIS_TERM_ID); 
                              
        COMMIT;                           

    END SCRIPT_CRIAR_PERIODO_ACADEMICO;

    PROCEDURE SCRIPT_ATUALIZAR_PERIODO_ACA IS

        Cursor C_PERIODO IS
            SELECT distinct CPRV.SIS_TERM_ID
                  ,CPRV.START_AT
                  ,CPRV.END_AT
              FROM CANVAS_PERIODOS_ACADEMICO   CPER
                  ,(select sis_term_id
                          ,max(END_AT) END_AT
                          ,max(START_AT) START_AT
                      from CANVAS_PERIODO_ACADEMICO_V
                     group by sis_term_id)  CPRV
            WHERE CPER.SIS_TERM_ID = CPRV.SIS_TERM_ID
              AND (CPER.START_AT   < CPRV.START_AT
                OR CPER.END_AT     < CPRV.END_AT); 
                
        wSIS_TERM_ID  VARCHAR2(100);
        wSTART_AT     DATE;
        wEND_AT       DATE;               

    BEGIN

        OPEN C_PERIODO;
        FETCH C_PERIODO INTO wSIS_TERM_ID,wSTART_AT,wEND_AT;
        WHILE C_PERIODO%FOUND LOOP

          UPDATE CANVAS_PERIODOS_ACADEMICO
            SET START_AT = wSTART_AT
               ,END_AT   = wEND_AT
               ,DT_UPDT  = NULL
          WHERE SIS_TERM_ID = wSIS_TERM_ID;

          FETCH C_PERIODO INTO wSIS_TERM_ID,wSTART_AT,wEND_AT;  

        END LOOP;
        COMMIT;
        CLOSE C_PERIODO; 

    END SCRIPT_ATUALIZAR_PERIODO_ACA;

    PROCEDURE SCRIPT_CRIAR_USUARIO(pID_CURSO NUMBER, pID_TURMA VARCHAR2, pNR_ANO_SEMESTRE VARCHAR2) IS

    BEGIN

        /*Insere usuários*/
        INSERT INTO CANVAS_USUARIOS
            SELECT DISTINCT
                   util.REMOVE_ALL_SPECIAL_CHARACTER(CUSU.FULL_NAME) FULL_NAME
                  ,util.REMOVE_ALL_SPECIAL_CHARACTER(CUSU.SHORT_NAME) SHORT_NAME
                  ,util.REMOVE_ALL_SPECIAL_CHARACTER(CUSU.SORTABLE_NAME) SORTABLE_NAME
                  ,CUSU.EMAIL           
                  ,CUSU.LOGIN           
                  ,CUSU.PASSWORD        
                  ,CUSU.SIS_USER_ID     
                  ,CUSU.AUTH_PROVIDER_ID
                  ,NULL DT_INCL         
                  ,SYSDATE DT_UPDT         
                  ,NULL CANVAS_ID       
              FROM CANVAS_USUARIOS_V CUSU
            WHERE NOT EXISTS (SELECT 1
                                FROM CANVAS_USUARIOS CUSU1
                              WHERE CUSU1.LOGIN = CUSU.LOGIN);
                              
        COMMIT; 

    END SCRIPT_CRIAR_USUARIO;

    PROCEDURE SCRIPT_ATUALIZAR_USUARIO IS

        /*Consulta se existe alteração do cadastro de usuários*/
        Cursor C_ATUALIZA IS
            SELECT CUSV.LOGIN        
                  ,util.REMOVE_ALL_SPECIAL_CHARACTER(CUSV.FULL_NAME) FULL_NAME
                  ,util.REMOVE_ALL_SPECIAL_CHARACTER(CUSV.SHORT_NAME) SHORT_NAME
                  ,util.REMOVE_ALL_SPECIAL_CHARACTER(CUSV.SORTABLE_NAME) SORTABLE_NAME
                  ,CUSV.EMAIL        
              FROM CANVAS_USUARIOS_V CUSV
                  ,CANVAS_USUARIOS   CUSU
            WHERE  CUSV.LOGIN           = CUSU.LOGIN
              AND  CUSU.CANVAS_ID      IS NOT NULL
              AND (CUSV.FULL_NAME      != CUSU.FULL_NAME
                OR CUSV.SHORT_NAME     != CUSU.SHORT_NAME
                OR CUSV.SORTABLE_NAME  != CUSU.SORTABLE_NAME
                OR CUSV.EMAIL          != CUSU.EMAIL);
                
        R_ATUALIZA  C_ATUALIZA%ROWTYPE;  

    BEGIN

        OPEN C_ATUALIZA;
        FETCH C_ATUALIZA INTO R_ATUALIZA;
        WHILE C_ATUALIZA%FOUND LOOP
           
          UPDATE CANVAS_USUARIOS
            SET FULL_NAME     = R_ATUALIZA.FULL_NAME
               ,SHORT_NAME    = R_ATUALIZA.SHORT_NAME
               ,SORTABLE_NAME = R_ATUALIZA.SORTABLE_NAME
               ,EMAIL         = R_ATUALIZA.EMAIL
               ,DT_UPDT       = NULL
          WHERE LOGIN = R_ATUALIZA.LOGIN;      
          
          FETCH C_ATUALIZA INTO R_ATUALIZA;
          
        END LOOP;
        COMMIT;
        CLOSE C_ATUALIZA;

    END SCRIPT_ATUALIZAR_USUARIO;

    PROCEDURE SCRIPT_CRIAR_CURSO(pID_CURSO NUMBER, pID_TURMA VARCHAR2, pNR_ANO_SEMESTRE VARCHAR2) IS

    BEGIN

        /*Insere cursos*/
        INSERT INTO CANVAS_CURSOS
            SELECT DISTINCT 
                   CCUR.ACCOUNT_ID       
                  ,CCUR.NAME             
                  ,CCUR.CODE
                  ,CCUR.START_AT         
                  ,CCUR.END_AT
                  ,CCUR.RESTRICT_TO_DATES
                  ,CCUR.SIS_MASTER_ID    
                  ,CCUR.SIS_TERM_ID      
                  ,CCUR.SIS_COURSE_ID    
                  ,CCUR.PUBLISH          
                  ,CCUR.IMPORT_CONTENT   
                  ,NULL DT_INCL
                  ,SYSDATE DT_UPDT
                  ,NULL CANVAS_ID
                  ,NULL EVENT
              FROM CANVAS_CURSOS_V CCUR
            WHERE (ID_CURSO = pID_CURSO or pID_CURSO is null)
              and (id_turma = pid_turma or pid_turma is null)
              and (nr_ano_semestre = pnr_ano_semestre or pnr_ano_semestre is null)
              AND NOT EXISTS (SELECT 1
                                FROM CANVAS_CURSOS CCUR1
                              WHERE CCUR.SIS_COURSE_ID = CCUR1.SIS_COURSE_ID)
              AND EXISTS (SELECT 1
                            FROM CANVAS_PERIODOS_ACADEMICO CPER
                          WHERE CPER.SIS_TERM_ID = CCUR.SIS_TERM_ID);
                              
        COMMIT;                               

    END SCRIPT_CRIAR_CURSO;

    PROCEDURE SCRIPT_ATUALIZAR_CURSO IS

        /*Consulta cursos onde o termino do periodo academico é inferior a data de hoje*/
        Cursor C_CONCLUIR IS
            SELECT CCUR.SIS_COURSE_ID
              FROM CANVAS_CURSOS            CCUR
                  ,CANVAS_PERIODOS_ACADEMICO CPER
            WHERE CCUR.SIS_TERM_ID   = CPER.SIS_TERM_ID
              AND CCUR.CANVAS_ID     IS NOT NULL
              AND TRUNC(SYSDATE)     > TRUNC(CPER.END_AT)
              AND (CCUR.EVENT        != 'conclude' or CCUR.EVENT is null);
            
         /*Cursos que foram marcado para concluir, mas que ainda não foi encerrado*/   
        cursor C_VALIDATE_BEFORE_UPDT is
            SELECT CCUR.SIS_COURSE_ID
              FROM CANVAS_CURSOS            CCUR
                  ,CANVAS_PERIODOS_ACADEMICO CPER
            WHERE CCUR.SIS_TERM_ID   = CPER.SIS_TERM_ID
              AND CCUR.CANVAS_ID     IS NOT NULL
              AND CCUR.DT_UPDT       IS NULL
              AND TRUNC(SYSDATE)     < TRUNC(CPER.END_AT)
              AND CCUR.EVENT         = 'conclude';
        
        /*Cursos que ja foram enviado como concluido, mas que ainda não foi encerrado*/
        cursor C_VALIDATE_AFTER_UPDT is
            SELECT CCUR.SIS_COURSE_ID
              FROM CANVAS_CURSOS            CCUR
                  ,CANVAS_PERIODOS_ACADEMICO CPER
            WHERE CCUR.SIS_TERM_ID   = CPER.SIS_TERM_ID
              AND CCUR.CANVAS_ID     IS NOT NULL
              AND CCUR.DT_UPDT       IS not NULL
              AND TRUNC(SYSDATE)     < TRUNC(CPER.END_AT)
              AND CCUR.EVENT         = 'conclude';
    
        wSIS_COURSE_ID VARCHAR2(100);

    BEGIN
    
        OPEN C_VALIDATE_BEFORE_UPDT;
        FETCH C_VALIDATE_BEFORE_UPDT INTO wSIS_COURSE_ID;
        WHILE C_VALIDATE_BEFORE_UPDT%FOUND LOOP
            
            UPDATE CANVAS_CURSOS
                SET EVENT   = NULL
                   ,DT_UPDT = SYSDATE 
              WHERE SIS_COURSE_ID = wSIS_COURSE_ID;
            
            FETCH C_VALIDATE_BEFORE_UPDT INTO wSIS_COURSE_ID;
            
        END LOOP;
        CLOSE C_VALIDATE_BEFORE_UPDT;
        
        commit;
        
        OPEN C_VALIDATE_AFTER_UPDT;
        FETCH C_VALIDATE_AFTER_UPDT INTO wSIS_COURSE_ID;
        WHILE C_VALIDATE_AFTER_UPDT%FOUND LOOP
            
            UPDATE CANVAS_CURSOS
                SET EVENT   = 'offer'
                   ,DT_UPDT = null 
              WHERE SIS_COURSE_ID = wSIS_COURSE_ID;
            FETCH C_VALIDATE_AFTER_UPDT INTO wSIS_COURSE_ID;      
        END LOOP;
        CLOSE C_VALIDATE_AFTER_UPDT;
        
        commit;
        
        OPEN C_CONCLUIR;
        FETCH C_CONCLUIR INTO wSIS_COURSE_ID;
        WHILE C_CONCLUIR%FOUND LOOP

          UPDATE CANVAS_CURSOS
            SET EVENT   = 'conclude'
               ,DT_UPDT = NULL 
          WHERE SIS_COURSE_ID = wSIS_COURSE_ID;
          
          FETCH C_CONCLUIR INTO wSIS_COURSE_ID;
          
        END LOOP;
        COMMIT;
        CLOSE C_CONCLUIR;

    END SCRIPT_ATUALIZAR_CURSO;
    
    procedure script_excluir_curso is
        cursor c_curso_not_exist is
            select *
              from canvas_cursos cc
             WHERE CC.CANVAS_ID IS NULL 
               and CC.SIS_COURSE_ID <> '20181.ENAD'
               and not exists (select 1
                                 from canvas_cursos_v ccv
                                where cc.ACCOUNT_ID    = ccv.ACCOUNT_ID
                                  and cc.SIS_COURSE_ID = ccv.SIS_COURSE_ID
                                  and cc.SIS_MASTER_ID = ccv.SIS_MASTER_ID
                                  and cc.SIS_TERM_ID   = ccv.SIS_TERM_ID);
        
        cursor c_secoes(p_sis_course_id varchar2) is
            select * 
              from canvas_secoes
             where sis_course_id = p_sis_course_id
               and canvas_id is null;

        w_curso c_curso_not_exist%rowtype;
        w_secao c_secoes%rowtype;
    begin
     
        open c_curso_not_exist;
        fetch c_curso_not_exist into w_curso;
        while c_curso_not_exist%found loop
            open c_secoes(w_curso.sis_course_id);
            fetch c_secoes into w_secao;
            if c_secoes%found then
                delete from canvas_inscricoes where sis_section_id = w_secao.sis_section_id and canvas_id is null;
                delete from canvas_secoes where sis_section_id = w_secao.sis_section_id and canvas_id is null;
            end if;
            close c_secoes;
            delete from canvas_cursos WHERE sis_course_id = w_curso.sis_course_id and canvas_id is null;
            fetch c_curso_not_exist into w_curso;
        end loop;
        close c_curso_not_exist;
        
    end;

    PROCEDURE SCRIPT_CRIAR_SECAO(pID_CURSO NUMBER, pID_TURMA VARCHAR2, pNR_ANO_SEMESTRE VARCHAR2) IS

    BEGIN

        /*Insere seções*/
        INSERT INTO CANVAS_SECOES
            SELECT DISTINCT
                   CSEC.SIS_COURSE_ID    
                  ,CSEC.NAME             
                  ,CSEC.SIS_SECTION_ID   
                  ,CSEC.START_AT         
                  ,CSEC.END_AT           
                  ,CSEC.RESTRICT_TO_DATES
                  ,CSEC.ISOLATE_SECTION  
                  ,NULL DT_INCL          
                  ,SYSDATE DT_UPDT          
                  ,NULL CANVAS_ID     
                  ,NULL GROUP_ID
              FROM CANVAS_SECOES_V CSEC
            WHERE (ID_CURSO = pID_CURSO or pID_CURSO is null)
              and (id_turma = pid_turma or pid_turma is null)
              and (nr_ano_semestre = pnr_ano_semestre or pnr_ano_semestre is null)
              AND NOT EXISTS (SELECT 1
                                FROM CANVAS_SECOES CSEC1
                               WHERE CSEC1.SIS_COURSE_ID = CSEC.SIS_COURSE_ID
                                 AND CSEC1.SIS_SECTION_ID = CSEC.SIS_SECTION_ID)
              AND EXISTS (SELECT 1
                            FROM CANVAS_CURSOS CCUR
                           WHERE CCUR.SIS_COURSE_ID = CSEC.SIS_COURSE_ID); 
                          
        COMMIT;                         

    END SCRIPT_CRIAR_SECAO;

    PROCEDURE SCRIPT_ATUALIZAR_SECAO IS

        /*Consulta se existe alteração na data de inicio e termino da seção*/
        Cursor C_ATUALIZA IS
            SELECT CSEC.SIS_COURSE_ID                 
                  ,CSEC.SIS_SECTION_ID            
                  ,CSEV.START_AT
                  ,CSEV.END_AT           
              FROM CANVAS_SECOES_V CSEV
                  ,CANVAS_SECOES   CSEC
            WHERE  CSEV.SIS_COURSE_ID  = CSEC.SIS_COURSE_ID
              AND  CSEV.SIS_SECTION_ID  = CSEC.SIS_SECTION_ID
              AND CSEC.CANVAS_ID       IS NOT NULL
              AND (CSEV.START_AT      != CSEC.START_AT
                OR CSEV.END_AT        != CSEC.END_AT);   

        R_ATUALIZA   C_ATUALIZA%ROWTYPE;

    BEGIN

        OPEN C_ATUALIZA;
        FETCH C_ATUALIZA INTO R_ATUALIZA;
        WHILE C_ATUALIZA%FOUND LOOP

          UPDATE CANVAS_SECOES
            SET START_AT = R_ATUALIZA.START_AT
               ,END_AT   = R_ATUALIZA.END_AT
               ,DT_UPDT  = NULL
          WHERE SIS_COURSE_ID  = R_ATUALIZA.SIS_COURSE_ID
            AND SIS_SECTION_ID = R_ATUALIZA.SIS_SECTION_ID;
            
          FETCH C_ATUALIZA INTO R_ATUALIZA;
          
        END LOOP;
        COMMIT;
        CLOSE C_ATUALIZA;

    END SCRIPT_ATUALIZAR_SECAO;

    PROCEDURE SCRIPT_CRIAR_INSCRICAO(pID_CURSO NUMBER, pid_turma varchar2, pnr_ano_semestre varchar2) IS

    BEGIN

        /*Insere inscrição*/
        INSERT INTO CANVAS_INSCRICOES
            SELECT DISTINCT
                   CINS.SIS_USER_ID          
                  ,CINS.TYPE 
                  ,CINS.ROLE_ID                        
                  ,CINS.SIS_SECTION_ID   
                  ,RTRIM(CINS.STATE) STATE            
                  ,CINS.LIMIT_INTERACTION
                  ,CINS.SEND_NOTIFICATION
                  ,NULL DT_INCL          
                  ,SYSDATE DT_UPDT          
                  ,NULL CANVAS_ID
                  ,NULL ACTION         
              FROM CANVAS_INSCRICOES_V CINS
            WHERE (ID_CURSO = pID_CURSO or pID_CURSO is null)
              and (id_turma = pid_turma or pid_turma is null)
              and (nr_ano_semestre = pnr_ano_semestre or pnr_ano_semestre is null)
              AND NOT EXISTS (SELECT 1
                                FROM CANVAS_INSCRICOES CINS1
                              WHERE CINS1.SIS_SECTION_ID = CINS.SIS_SECTION_ID
                                 and trim(CINS.role_id)  = trim(CINS1.role_id)
                                AND CINS1.SIS_USER_ID    = CINS.SIS_USER_ID)
              AND EXISTS (SELECT 1
                            FROM CANVAS_SECOES CSEC
                          WHERE CSEC.SIS_SECTION_ID = CINS.SIS_SECTION_ID)
              AND EXISTS (SELECT 1
                            FROM CANVAS_USUARIOS CUSU
                          WHERE CINS.SIS_USER_ID  = CUSU.LOGIN);
                          
        COMMIT;                                              

    END SCRIPT_CRIAR_INSCRICAO;

    PROCEDURE SCRIPT_INATIVAR_INSCRICAO IS

        /*Consulta inscrição que na tabela esta active e não exista na view*/
        Cursor C_INSCRICOES IS
            SELECT CINS.SIS_SECTION_ID
                  ,CINS.SIS_USER_ID
                  ,CINS.ROLE_ID
              FROM CANVAS_INSCRICOES CINS
             WHERE STATE      = 'active'
               AND CINS.CANVAS_ID IS NOT NULL
               AND CINS.SIS_SECTION_ID <> '20181.ENAD.DEZ2018'
               AND NOT EXISTS (SELECT 1
                                 FROM CANVAS_SECOES_EXCL CCE
                                WHERE CCE.SIS_SECTION_ID = CINS.SIS_SECTION_ID
                                  AND CCE.CANVAS_ID IS NOT NULL)
               AND NOT EXISTS (SELECT 1
                                 FROM CANVAS_INSCRICOES_V CINS1
                               WHERE CINS.SIS_SECTION_ID = CINS1.SIS_SECTION_ID
                                 and trim(CINS.role_id)  = trim(CINS1.role_id)
                                 AND CINS.SIS_USER_ID    = CINS1.SIS_USER_ID);

        wSIS_SECTION_ID  VARCHAR2(100);
        wUSER_ID         VARCHAR2(100);
        Wrole_id         varchar2(2);

    BEGIN

        OPEN C_INSCRICOES;
        FETCH C_INSCRICOES INTO wSIS_SECTION_ID,wUSER_ID, Wrole_id;
        WHILE C_INSCRICOES%FOUND LOOP
          
          UPDATE CANVAS_INSCRICOES
            SET ACTION  = 'deactivate'
               ,DT_UPDT = NULL
          WHERE SIS_SECTION_ID = wSIS_SECTION_ID 
            AND SIS_USER_ID    = wUSER_ID
            and trim(role_id)  = trim(Wrole_id);
          
          FETCH C_INSCRICOES INTO wSIS_SECTION_ID,wUSER_ID, wROLE_ID; 
             
        END LOOP;
        COMMIT;  
        CLOSE C_INSCRICOES;

    END SCRIPT_INATIVAR_INSCRICAO;

    PROCEDURE SCRIPT_REATIVAR_INSCRICAO IS

        /*Consulta inscrição que na tabela esta inactive e na visão esta active*/
        Cursor C_INSCRICOES IS
            SELECT CINS.SIS_SECTION_ID
                  ,CINS.SIS_USER_ID
                  ,CINS.ROLE_ID
              FROM CANVAS_INSCRICOES CINS
            WHERE CINS.STATE  = 'inactive'
              and CINS.canvas_id is not null
              AND EXISTS (SELECT 1
                            FROM CANVAS_INSCRICOES_V CINV 
                          WHERE CINS.SIS_SECTION_ID = CINV.SIS_SECTION_ID
                            AND CINS.SIS_USER_ID    = CINV.SIS_USER_ID
                            and trim(cins.role_id)  = trim(cinv.role_id)
                            AND CINV.STATE          = 'active');
                                
        wSIS_SECTION_ID  VARCHAR2(100);
        wUSER_ID         VARCHAR2(100);
        wROLE_ID         VARCHAR2(2);

    BEGIN

        OPEN C_INSCRICOES;
        FETCH C_INSCRICOES INTO wSIS_SECTION_ID,wUSER_ID, wROLE_ID;
        WHILE C_INSCRICOES%FOUND LOOP
          
          UPDATE CANVAS_INSCRICOES
            SET ACTION  = 'reactivate'
               ,DT_UPDT = NULL
          WHERE SIS_SECTION_ID = wSIS_SECTION_ID 
            AND SIS_USER_ID    = wUSER_ID
            AND trim(ROLE_ID)  = trim(wROLE_ID);
          
          FETCH C_INSCRICOES INTO wSIS_SECTION_ID,wUSER_ID,wROLE_ID; 
             
        END LOOP;
        COMMIT;  
        CLOSE C_INSCRICOES;

    END SCRIPT_REATIVAR_INSCRICAO;

    /****************************Termino Script********************************/
    

/********************************Inicio get/set********************************/

/**
    <p>
        Verificar se está apto para ser enviado ao canvas, com as seguintes regras;
    </p>
    <ul>
        <li>
            A matrícula deve estar com o status de inscrito.
        </li>
        <li>
            Ser rematricula.
        </li>
        <li>
            Ser rematricula.
        </li>
        <li>
            Ser rematricula.
        </li>
    </ul>
    
    @param  pnr_matricula       matrícula a ser consultada
    @param  pnr_ano_semestre    ano semestre
    @param  pid_turma           turma matrículada
    @param  pst_academico       status acadêmico atual
    
    @return apto para envio caso sim retornar 1 senão 7
*/
    function  get_status_academico(pnr_matricula varchar2, pnr_ano_semestre varchar2, pid_curso number, pid_turma varchar2, pst_academico varchar2) return varchar2 is
    
        Cursor C_MODALIDADE(pID_CURSO number) is
            SELECT ORIGEM_DOMINIO('CAC_CURSOS','ST_ESPECIALIZACAO',ST_ESPECIALIZACAO) TP_MODALIDADE
              from CAC_CURSOS 
             where ID_CURSO = pID_CURSO;
    
        cursor c_periodo_rematricula (pnr_ano_semestre varchar2, pid_turma varchar2, pTP_MODALIDADE in varchar2) is
            select 1
              from PORTAL_APLICACOES_DISPONIVEL
             where ID_APLICACAO    = 'URM-G'
               and TP_CURSO        = pTP_MODALIDADE
               and id_turma        like pid_turma||'%'
               and nr_ano_semestre = pnr_ano_semestre
               and trunc(sysdate)  >= dt_inicio;
            
        cursor c_aceite_eletronico(pnr_matricula varchar2, pnr_ano_semestre varchar2) is
            select id_pagina
              from CAC_ETAPAS_MATRICULA
             where nr_matricula    = pnr_matricula
               and nr_ano_semestre = pnr_ano_semestre
               and rownum          = 1
             order by dt_etapa desc;
            
        CURSOR C_TITULO (pNR_MATRICULA IN VARCHAR2, pNR_ANO_SEMESTRE IN VARCHAR2) IS
            SELECT 1 
              FROM(SELECT se1.E1_VALOR VL_TITULO
                         ,se1.E1_SALDO VL_SALDO
                         ,se1.E1_NATUREZ ID_NATUREZA
                         ,se1.E1_ZG3PARC NR_PARCELA
                         ,se1.E1_TIPO    TP_TITULO
                         ,to_date(se1.E1_VENCTO,'RRRRMMDD') DT_VENCTO
                         ,rpad(sed.ED_DESCRIC,100,' ') DS_TITULO         
                         ,0 SN_RESTRICAO --DECODE(RST.TOTAL,0,0,1) SN_RESTRICAO             
                     FROM se1010 se1
                         ,( select *
                              from FIN_BLOQUEIO_NATUREZAS xxx
                             where xxx.DS_ORIGEM   = 'UNIFIL'
                               and xxx.DT_CADASTRO = (select max(aaa.DT_CADASTRO)
                                                        from FIN_BLOQUEIO_NATUREZAS aaa
                                                       where aaa.DS_ORIGEM       = xxx.DS_ORIGEM
                                                         and aaa.DS_NATUREZA_INI = xxx.DS_NATUREZA_INI
                                                         and aaa.DS_NATUREZA_FIM = xxx.DS_NATUREZA_FIM))     blq
                  --  retirado pois tem que melhor analisar. pois talvez enquanto traz neste cursor não 
                  --  precisa ser olhado isso, analisar melhor                        
                  --       ,(SELECT COUNT(*) TOTAL
                  --          FROM FIN_RESTRICAO_UNIFIL urfn
                  --         WHERE urfn.NR_MATRICULA = rtrim(pNR_MATRICULA)
                  --           AND trunc(sysdate)    between trunc(urfn.DT_RESTRICAO) and trunc (urfn.DT_RESTRICAO_FINAL)
                  --           AND urfn.SN_LIBERADO  = 'S') RST                                
                         ,sed010 sed
                    WHERE se1.E1_FILIAL  = '01'
                      and se1.E1_ZC2NRMA = pNR_MATRICULA||' '
                      AND SE1.E1_ZC3ANSE = pNR_ANO_SEMESTRE
                      AND se1.E1_SALDO   > 0
                      AND se1.E1_VENCREA >= to_char((sysdate - 3), 'RRRRMMDD')
                      AND se1.D_E_L_E_T_ = ' '
                      AND se1.E1_ZG4ORTI = 'CES'
                      AND blq.DS_ORIGEM  = 'UNIFIL'
                      AND se1.E1_NATUREZ BETWEEN blq.DS_NATUREZA_INI AND blq.DS_NATUREZA_FIM
                      AND SE1.E1_ZG3PARC = '01'
                      and sed.ED_CODIGO  = se1.E1_NATUREZ)
                    WHERE SN_RESTRICAO   = 0;
               
        wTP_MODALIDADE      varchar2(10);
        wID_CURSO           number;
        wNR_MATRICULA       cac_matriculas.nr_matricula%type;
        wNR_ANO_SEMESTRE    cac_matriculas.nr_ano_semestre%type;
        wID_TURMA           cac_turmas.id_turma%type;
        wST_ACADEMICO       cac_matriculas.st_academico%type;
        wDUMMY              binary_integer;
        wID_PAGINA          cac_etapas_matricula.id_pagina%type;
        wRETORNO            varchar2(1);
    begin
        wNR_MATRICULA    := pnr_matricula;
        wNR_ANO_SEMESTRE := pnr_ano_semestre;
        wID_TURMA        := pid_turma;
        wID_CURSO        := pid_curso;
        wST_ACADEMICO    := pst_academico;
        util.p('-----------------------------------------INICIO----------------------------------------------------', is_debug);
        util.p('wNR_MATRICULA: '    || wNR_MATRICULA   , is_debug);
        util.p('wNR_ANO_SEMESTRE: ' || wNR_ANO_SEMESTRE, is_debug);
        util.p('wID_TURMA: '        || wID_TURMA       , is_debug);
        util.p('wID_CURSO: '        || wID_CURSO       , is_debug);
        util.p('wST_ACADEMICO: '    || wST_ACADEMICO   , is_debug);
        
        if wST_ACADEMICO != '7' then
            wRETORNO := pst_academico;
        elsif substr(wNR_MATRICULA, 1, 3) = substr(wNR_ANO_SEMESTRE, -3) then
            wRETORNO := pst_academico;
        else
            wRETORNO := pst_academico;
            util.p('-----------------------------------------------------------------------------------------------', is_debug);
            util.p('open C_MODALIDADE'       , is_debug);
            util.p('wID_CURSO: ' || wID_CURSO, is_debug);
            open C_MODALIDADE(wID_CURSO);
            fetch C_MODALIDADE into wTP_MODALIDADE;
            close C_MODALIDADE;
            util.p('RESPOSTA; '                        , is_debug);
            util.p('wTP_MODALIDADE: ' || wTP_MODALIDADE, is_debug);
            if wTP_MODALIDADE like '%EAD%' then
                wTP_MODALIDADE := 'EAD';
                wID_TURMA := substr(pid_turma, 1, instr(pid_turma, '@') + 1);
            else
                wTP_MODALIDADE := 'PRESENCIAL';
                wID_TURMA := 'X';
            end if;
            
            util.p('-----------------------------------------------------------------------------------------------', is_debug);
            util.p('open C_PERIODO_REMATRICULA'             , is_debug);
            util.p('wTP_MODALIDADE: '    || wTP_MODALIDADE  , is_debug);
            util.p('wID_TURMA: '         || wID_TURMA       , is_debug);
            util.p('wNR_ANO_SEMESTRE: '  || wNR_ANO_SEMESTRE, is_debug);
            open C_PERIODO_REMATRICULA(wNR_ANO_SEMESTRE, wID_TURMA, wTP_MODALIDADE);
            fetch C_PERIODO_REMATRICULA into wDUMMY;
            if C_PERIODO_REMATRICULA%FOUND then
                util.p('RESPOSTA; '         , is_debug);
                util.p('wDUMMY: '  || wDUMMY, is_debug);
                util.p('-----------------------------------------------------------------------------------------------', is_debug);
                util.p('open c_aceite_eletronico'              , is_debug);
                util.p('wNR_MATRICULA: '    || wNR_MATRICULA   , is_debug);
                util.p('wNR_ANO_SEMESTRE: ' || wNR_ANO_SEMESTRE, is_debug);
                open c_aceite_eletronico(wNR_MATRICULA, wNR_ANO_SEMESTRE);
                fetch c_aceite_eletronico into wID_PAGINA;
                close c_aceite_eletronico;
                util.p('RESPOSTA; '                 , is_debug);
                util.p('wID_PAGINA: '  || wID_PAGINA, is_debug);
                if coalesce(wID_PAGINA, 'VAZIO') = 'IMPRESSAO' then
                    util.p('-----------------------------------------------------------------------------------------------', is_debug);
                    util.p('open C_TITULO'                         , is_debug);
                    util.p('wNR_MATRICULA: '    || wNR_MATRICULA   , is_debug);
                    util.p('wNR_ANO_SEMESTRE: ' || wNR_ANO_SEMESTRE, is_debug);
                    open C_TITULO(pNR_MATRICULA, pNR_ANO_SEMESTRE);
                    fetch C_TITULO into wDUMMY;
                    if C_TITULO%found then
                        wRETORNO := '1';
                    end if;
                    util.p('RESPOSTA; '          , is_debug);
                    util.p('wDUMMY: '  || wDUMMY , is_debug);
                    close C_TITULO;                        
                end if;
            end if;
            close C_PERIODO_REMATRICULA;
            
        end if;
        
        
        util.p('-----------------------------------------FIM-------------------------------------------------------', is_debug);
        return wRETORNO;
        
        exception
            when others then
                return null;
    end;
    

/**
    Tenta padronizar a crição do objeto <em>PLJSON</em>s
    @param  p_json      string no formato json a ser transformado
    @param  p_nm_entity nome da entidade a ser trabalhado
    @return objeto json criado
*/
    function get_default_json(p_json clob, p_nm_entity varchar2) return pljson as
        w_str_json clob;
    begin
        if substr(p_json, 1, 1) = '[' then
            w_str_json := '{"'||p_nm_entity||'":'||p_json||'}';
        elsif substr(p_json, 1, 1) = p_nm_entity then
            null;
        else 
            w_str_json := '{"'||p_nm_entity||'":'||p_json||'}';
        end if;
        return pljson(w_str_json);
    end;
    
/**
    <p>
        Retorna a nota, do tipo <em>canvas_notas</em>, basicamente
        converte pljson para nota.
    </p>
    @param  p_js_nota   json a ser convertido para nota.
    @return nota.
*/
    function get_nota(p_js_nota pljson) return canvas_notas%rowtype is
        w_nota canvas_notas%rowtype;
    begin
        
        if p_js_nota.get('canvas_id').get_type = 'string' then
            w_nota.CANVAS_ID         := p_js_nota.get('canvas_id').get_string;
        elsif p_js_nota.get('canvas_id').get_type = 'number' then
            w_nota.CANVAS_ID         := p_js_nota.get('canvas_id').get_number;
        end if;
        
        w_nota.SIS_SECTION_ID    := p_js_nota.get('sis_section_id').str;
        w_nota.SIS_COURSE_ID     := p_js_nota.get('sis_course_id').str;
        
        if p_js_nota.get('sis_user_id').get_type = 'string' then
            w_nota.SIS_USER_ID       := p_js_nota.get('sis_user_id').get_string;
        elsif p_js_nota.get('sis_user_id').get_type = 'number' then
            w_nota.SIS_USER_ID       := p_js_nota.get('sis_user_id').get_number;
        end if;
        
        w_nota.TYPE              := p_js_nota.get('type').str;
        w_nota.LAST_ACTIVITY_AT  := p_js_nota.get('last_activity_at').str;
               
        if p_js_nota.get('current_score').get_type = 'string' then
            w_nota.CURRENT_SCORE     := to_number(p_js_nota.get('current_score').str, '99999999.99');
        else
            w_nota.CURRENT_SCORE     := p_js_nota.get('current_score').num;
        end if;
        
        if p_js_nota.get('final_score').get_type = 'string' then
            w_nota.FINAL_SCORE       := to_number(p_js_nota.get('final_score').str, '99999999.99');
        else
            w_nota.FINAL_SCORE       := p_js_nota.get('final_score').num;
        end if;
        
        if p_js_nota.get('current_grade').get_type = 'string' then
            w_nota.CURRENT_GRADE     := p_js_nota.get('current_grade').get_string;
        elsif p_js_nota.get('current_grade').get_type = 'number' then
            w_nota.CURRENT_GRADE     := p_js_nota.get('current_grade').get_number;
        end if;
        
        if p_js_nota.get('current_grade').get_type = 'string' then
            w_nota.FINAL_GRADE       := p_js_nota.get('final_grade').get_string;
        elsif p_js_nota.get('current_grade').get_type = 'string' then
            w_nota.FINAL_GRADE       := p_js_nota.get('final_grade').get_number;
        end if;
               
        w_nota.STATE             := p_js_nota.get('state').str;
        w_nota.DT_INCL           := sysdate;
        return w_nota;
    end;

/********************************Termino get/set*******************************/


    /****************************Inicio Utils**********************************/
    
/**

*/
    function util_is_json(p_str_json clob) return boolean is
        v_json pljson;
    begin
        v_json := pljson(p_str_json);
        return true;
    exception
        when others then
            return false;
    end;
  
/**
    Remover propriedades vazias do json.
    @param  p_json json a ser trabalhado.
    @return pljson objeto sem colunas vazias.
*/
    function util_remove_empty_column(p_json pljson) return pljson is
        w_json pljson;
    begin
        w_json := p_json;
--        util.p('p_json.count:'||p_json.count);
        for i in 1..p_json.count loop
            if (p_json.get(i).is_string and p_json.get(i).str is null) or 
            (p_json.get(i).is_number and p_json.get(i).num is null) then
                declare
                    nm_column varchar2(1000);
                begin
                    nm_column := p_json.get(i).mapname;
                    w_json.remove(nm_column);
                end;
            end if;
        end loop;
        return w_json;
    end util_remove_empty_column;
    
    
   function util_all_atribute_to_lower(p_json clob) return clob;
/**
    Troca os valores na variavel @p_has_tag onde existir <tag> pelo valor 
    existente no json, caso não existir a tag no json verificar manualmente.
    
    @param  p_has_tag   string que contém tags a serem trocados
    @param  p_val_tag   json que contém o valor da tag
    @return novo @p_has_tag após realizar a troca da(s) tag(s)
*/
    function util_replace_tag(p_has_tag varchar2, p_val_tag clob) return varchar2 is
        w_new  varchar2(500);
        w_tag  varchar2(200);
        w_json pljson;

--        p_has_tag varchar2(300) := 'update canvas_inscricoes set DT_UPDT = sysdate, state = <state> where <teste>'; 
--        p_val_tag clob := '{"id":"672", "sis_section_id":"CON@1004.CON@401K.20181", "sis_course_id":"CON@1004.20181", "sis_user_id":"11449320929", "state":"inactive"}';
        
        function get_tag(p_has_tag varchar2) return varchar2 is
        begin
            return substr(p_has_tag, instr(p_has_tag, '<') + 1, (instr(p_has_tag, '>') - (instr(p_has_tag, '<') + 1)));
        end;
    begin
        if p_val_tag is not null then
            w_json := pljson(util_all_atribute_to_lower(p_val_tag));
            
            w_new := lower(p_has_tag);
            
            declare
                w_json_value pljson_value;
            begin
                while w_new like '%<%' loop
                    w_tag := get_tag(w_new);
                    if w_tag = 'canvas_id' then
                        w_json_value := w_json.get('id');
                    else
                        w_json_value := w_json.get(w_tag);
                    end if;
                    if w_json_value is null then
                        raise e_no_tag_found;
                        exit;
                    else
                        if w_json_value.is_string then
                            w_new := replace(w_new, '<'||w_tag||'>', w_json_value.get_string);
                        elsif w_json_value.is_number then
                            w_new := replace(w_new, '<'||w_tag||'>', w_json_value.get_number);
                        elsif w_json_value.is_null then
                            w_new := replace(w_new, '<'||w_tag||'>', w_json_value.get_null);
                        elsif w_json_value.is_bool then
                            if w_json_value.get_bool then
                                w_new := replace(w_new, '<'||w_tag||'>', 'true');
                            else
                                w_new := replace(w_new, '<'||w_tag||'>', 'false');
                            end if;
                        end if;
                    end if;
                end loop;
            end;
        end if;
        return w_new;
    end;
    
/**
    Busca a propriedade informado por parâmetro (<em>p_nm_property</em>) se 
    encontrar retorna 
    @param  p_v1            objeto que contem a propridade
    @param  p_nm_property   nome da propridade a ser encontrada
    @return caso existir true senão false
*/
    function util_contains_properties(p_v1 pljson, p_nm_property varchar2) return boolean as
        property_exist boolean;
      begin
        property_exist := false;
        for i in 1..p_v1.count loop
            if property_exist then
                exit;
            end if;
            if p_v1.get(i).typeval in (1, 2) then
                property_exist := util_contains_properties(pljson(p_v1.get(i)), p_nm_property);
                if property_exist then
                    exit;
                end if;
            else
                if p_v1.get(i).mapname = p_nm_property then
                    property_exist := true;
                    exit;
                end if;
            end if;
        end loop;
        return property_exist;
      end;
/**
    Busca a propriedade (requerido) informado por parâmetro,  
    <em>p_v1</em> espera se que seja um dos templates declarados
    no spec dessa package, pois contém quais propriedades são
    obrigatorios, existir para o envio.
    
    @param  p_v1    objeto que contém as propridades
    @param  p_v2    objeto a ser validado
    @param  exact   ainda não definido
    @return caso todas as propriedades obrigatorias existir em <em>p_v2</em> então retorna true senão false.
*/
      function util_contains_properties(p_v1 pljson, p_v2 pljson, exact boolean default false) return boolean as
        w_jl1 pljson_list;
        w_jl2 pljson_list;
        exist_propriedade boolean;
        
      begin
        w_jl1 := p_v1.get_values;
        w_jl2 := p_v2.get_values;
--        w_jl1.print;
--        w_jl2.print;
        util.p('tamanho:'||w_jl1.count, is_debug);
        exist_propriedade := true;
        for i in 1..w_jl1.count loop
            if not exist_propriedade then
                exit;
            end if;
            if is_debug then 
                util.p('typeval:'||w_jl1.get(i).typeval);
                util.p('str:'||w_jl1.get(i).str); 
            end if;
            if w_jl1.get(i).typeval = 1 then
                exist_propriedade := util_contains_properties(pljson(w_jl1.get(i)), p_v2);
            elsif w_jl1.get(i).typeval = 3 and w_jl1.get(i).str like '%(requerido)%' then
    --            isEqual := exists_property(w_jl1.get(i).mapname, p_v2);
                if is_debug then util.p('existe propriedade '||w_jl1.get(i).mapname||'?'); end if;
                if not util_contains_properties(p_v2, w_jl1.get(i).mapname) then
                    if is_debug then util.p('não'); end if;
                    exist_propriedade := false;
                else 
                    if is_debug then util.p('sim'); end if;
                end if;
            end if;
        end loop;
        return exist_propriedade;
      end;
    
/*
    Executar sql.
    
    @param  p_sql   comando a ser executado.
    @return se executou com sucesso retorna true se não false.
    
*/
    function util_execute_sql(p_sql varchar2, r_msg out clob) return boolean is
    
        c               NUMBER;
        dummy           NUMBER;
        is_updated      boolean := false;

    begin
        --OLD WAY
--        EXECUTE IMMEDIATE p_sql;
--        if sql%rowcount > 0 then
--            commit;
--            return true;
--        else
--            return false;
--        end if;
        
        c := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(c, p_sql, DBMS_SQL.NATIVE);
        dummy := DBMS_SQL.EXECUTE(c);
        if dummy > 0 then
            is_updated := true;
        end if;
        DBMS_SQL.CLOSE_CURSOR(c);
        return is_updated;
        exception 
            when others then
                IF DBMS_SQL.IS_OPEN(c) THEN
                    DBMS_SQL.CLOSE_CURSOR(c);
                END IF;
                r_msg := r_msg || chr(10) || p_sql;
                r_msg := r_msg || chr(10) || 'Inicio Erro (util_execute_sql):';
                r_msg := r_msg || chr(10) || util.get_erro;
                r_msg := r_msg || chr(10) || 'Fim Erro (util_execute_sql)';
                return is_updated;
    end util_execute_sql;
    
/*
    Validar formato json conforme template passado por parâmetro,
    deve utilizar os templates disponíveis no spec desse pacote,
    para cada entidade/serviço utilizar o formato correto.
    
    @param    p_template          json template para ser comparado
    @param    p_validate          json a ser validado
    @param    p_validate_value    (opcional) validar os valores, por padrão não validar apenas os nomes das propriedades
    
    @return   <b>boolean:</b> caso os atributos/valores sejam iguais retorna verdadeiro se não falso
*/
    function util_validate_json(p_template varchar2, p_validate varchar2, p_validate_value boolean default false) return boolean is
        w_template pljson;
        w_validate pljson;
        
        bo_retorno boolean;
    begin
        w_template := pljson(p_template);
        w_validate := pljson(p_validate);
--        w_template.print;
--        w_validate.print;
--        bo_retorno := json_helper.equals_keys(w_template, w_validate);
--        bo_retorno := pljson_helper.contains(w_template, w_validate, false);
        
--        util.p('util_validate_json');
--        
        bo_retorno := util_contains_properties(w_template, w_validate, false);
--        if bo_retorno then
--            util.p('bo_retorno:true');
--        else
--            util.p('bo_retorno:false');
--        end if;
--        bo_retorno := true; 
        
--        if bo_retorno then
--            p('bo_retorno is true');
----            bo_retorno := json_helper.equals_keys(w_validate, w_template);
--        else
--            p('bo_retorno is false');
--        end if;
        return bo_retorno;
    end util_validate_json;
    
    --DEPRECATED
    function util_test_validate_json(p_template varchar2, p_validate varchar2, p_validate_value boolean default false) return boolean is
        w_template pljson;
        w_validate pljson;
        
        bo_retorno boolean;
    begin
        w_template := pljson(p_template);
        w_validate := pljson(p_validate);
        bo_retorno := util_contains_properties(w_template, w_validate, false);
        if bo_retorno then
            util.p('bo_retorno:true');
        else
            util.p('bo_retorno:false');
        end if;
        return bo_retorno;
    end util_test_validate_json;
    
/**
    Percorre a lista de valores de retorno de resposta da requisição
    e add na váriavel r_msg
    
    @param  p_valores     lista de valores (resposta do servidor)
    @return r_msg         log
*/
    procedure util_show_result(p_dados r_dados, r_msg out clob) as
        v r_valor;
        w_nm_propriedade v.atributo%type;
    begin
        r_msg := r_msg || chr(10) || 'Mostrar resultado da requisição;';
        w_nm_propriedade := p_dados.first;
        while w_nm_propriedade is not null loop
            r_msg := r_msg || chr(10) || '['||w_nm_propriedade||']'||p_dados(w_nm_propriedade).atributo||' => '||p_dados(w_nm_propriedade).valor;
            w_nm_propriedade := p_dados.next(w_nm_propriedade);
        end loop ;
--        old
--        for i in 1..p_valores.last loop
--            if i = 1 then
--                if p_valores(i).isErro then
--                    r_msg := r_msg || chr(10) || 'Inicio Erro';
--                end if;
--            end if;
--            r_msg := r_msg || chr(10) || '['||i||']'||p_valores(i).atributo||' => '||p_valores(i).valor;
--            if i = p_valores.last then
--                if p_valores(i).isErro then
--                    r_msg := r_msg || chr(10) || 'Fim Erro';
--                end if;
--            end if;
--        end loop;
    end util_show_result;
    
/**
    Percorre o objeto json da requisição e add na váriavel r_msg 
    
    @param  p_js    json (resposta do servidor)
    @param  r_msg   <b>retorna</b> o log
*/
    procedure util_show_result(p_js pljson, r_msg out clob) as
    begin
        r_msg := r_msg || chr(10) || 'Mostrar resultado da requisição;';
        r_msg := r_msg || chr(10) || p_js.to_char();
    end util_show_result;
    
/**
    Inserir dados na tabela de log do canvas.
    
    @param  p_msg       dados de log
    @param  p_nm_table  nome da tabela
    @param  p_nm_metodo função/procedimento/metodo
*/
    procedure util_insert_log(p_msg clob, p_nm_table varchar2, p_nm_metodo varchar2) is
        w_msg clob;
    begin
        /*insert into canvas_log
                       (nm_table
                       ,ds_log
                       ,nm_metodo)
                 values(p_nm_table
                       ,p_msg
                       ,p_nm_metodo);*/
        
        if UPPER(p_msg) like '%LINUX COMMAND%' OR upper(p_msg) like '%ERROR%' then 
            w_msg := p_msg;
            insert into canvas_log
                       (nm_table
                       ,ds_log
                       ,nm_metodo)
                 values(p_nm_table
                       ,p_msg
                       ,p_nm_metodo);
                       
            if upper(p_msg) like '%ERROR%' then
                declare
                    v_assunto varchar2(1000) := 'Integração Canvas - '||p_nm_table||' - '||p_nm_metodo||' ('||to_char(sysdate, 'dd/mm/rrrr HH24:mi:ss')||')';
    --                v_mensagem varchar2(2000);
                begin
    --                util.plob('<pre>'||replace(w_msg, chr(10), '<br/>')||'</pre>');
    --                util.p('v_assunto:'||v_assunto);
                    util.send_email(p_assunto => v_assunto, p_mensagem => '<pre>'||replace(w_msg, chr(10), '<br/>')||'</pre>');
                end;
            end if;
        end if;
    end util_insert_log;
    
/**
    Objetivo: Converter e retornar string em formato json
    
    @param  jl_users   lista de json
    @param  p_type     tipo da requisição (user, course, etc)
    @return clob      json formatado conforme documentção
    @throws e_formato_json_invalido   formato da lista não condis com o formato padrão de usuário
*/
    function util_list_to_json(p_json_template varchar2,p_json_list pljson_list, p_type varchar2) return clob as
        w_json clob;
        
        j_json json;
        formato_valido boolean;
        
    begin
        j_json := pljson(p_json_list.get(1));
        formato_valido := true;
           
        
        if p_json_list.count > 1 then
            w_json := '{[';
        else
            w_json := '{';
        end if;
        
        for i in 1..p_json_list.count loop
            if formato_valido then
                j_json := pljson(p_json_list.get(i));
                if i = 1 then
                    if not(util_validate_json(p_json_template, '{"'||p_type||'":'||j_json.to_char||'}')) then
                        formato_valido := false;
                        raise e_formato_json_invalido;
                    end if;
                end if;
                if i = p_json_list.count then
                    w_json := w_json||'"'||p_type||'":'||j_json.to_char;
                else
                    w_json := w_json||'"'||p_type||'":'||j_json.to_char||',';
                end if;
            end if;
        end loop;
        if p_json_list.count > 1 then
            w_json := w_json||']}';
        else
            w_json := w_json||'}';
        end if;

        return w_json;
    end util_list_to_json;
    
/**
    Transformar todos os atributos do json em maiúsculo
    @param  p_json  string json
    @return json formatado
*/
    function util_all_atribute_to_upper(p_json clob) return clob is
        w_json clob;
    
    
        procedure replace_all(p_start integer, p_current_text clob) is
            tmp varchar2(200);
            w_start integer;
            init integer;
        begin
            if instr(p_current_text, '{', p_start) >= p_start then
                w_start := instr(p_current_text, ':', (p_start + 1)) - instr(p_current_text, '{', p_start);
                tmp := substr(p_current_text, instr(p_current_text, '{', p_start), w_start);
                replace_all(instr(p_current_text, ':', (p_start + 1)), replace(p_current_text, tmp, upper(tmp)));
            elsif instr(p_current_text, ',', p_start) > p_start then
                w_start := instr(p_current_text, ':', (p_start + 1)) - instr(p_current_text, ',', p_start);
                tmp := substr(p_current_text, instr(p_current_text, ',', p_start), w_start);
                replace_all(instr(p_current_text, ':', (p_start + 1)), replace(p_current_text, tmp, upper(tmp)));
            else
                w_json := p_current_text;
            end if;
        end;
    begin
        w_json := p_json;
        replace_all(1, w_json);
        return w_json;
    end util_all_atribute_to_upper;
    
/**
    Transformar todos os atributos do json em minusculo
    
    @param p_json string json
    @return json formatado
*/
    function util_all_atribute_to_lower(p_json clob) return clob is
        w_json clob;
    
        procedure replace_all(p_start integer, p_current_text clob) is
            tmp varchar2(200);
            w_start integer;
            init integer;
        begin
            if instr(p_current_text, '{', p_start) >= p_start then
                w_start := instr(p_current_text, ':', (p_start + 1)) - instr(p_current_text, '{', p_start);
                tmp := substr(p_current_text, instr(p_current_text, '{', p_start), w_start);
                replace_all(instr(p_current_text, ':', (p_start + 1)), replace(p_current_text, tmp, lower(tmp)));
            elsif instr(p_current_text, ',', p_start) > p_start then
                w_start := instr(p_current_text, ':', (p_start + 1)) - instr(p_current_text, ',', p_start);
                tmp := substr(p_current_text, instr(p_current_text, ',', p_start), w_start);
                replace_all(instr(p_current_text, ':', (p_start + 1)), replace(p_current_text, tmp, lower(tmp)));
            else
                w_json := p_current_text;
            end if;
        end;
    begin
        w_json := p_json;
        replace_all(1, w_json);
        --        canvas.p(w_json);
        return w_json;
    end;
    
/**
    Remover propriedades onde está marcado para remover (no template)
    @param    p_o_json            remover daqui
    @param    p_o_template_json   consta quais campos devem ser removidos
    @return   objeto json apenas com as propriedades necessárias
*/
    function util_remove_property(p_o_json pljson, p_o_template_json pljson) return pljson is
        
        r_o_json pljson;
        w_o_template_json pljson;
        
        --if type is object
        w_tmp_template_json pljson;
        w_tmp_json pljson;
        w_nm_atribute varchar2(300);
        
        --if type is list
        w_tmp_template_list pljson_list;
        w_tmp_list pljson_list;
    begin
        r_o_json := p_o_json;
        w_o_template_json := p_o_template_json;
        
        
        for i in 1..w_o_template_json.count loop  
            
            if w_o_template_json.get(i).typeval = 1 then
                
                w_tmp_template_json := pljson(w_o_template_json.get(i));
                w_nm_atribute := lower(w_o_template_json.get(i).mapname);
                
                if r_o_json.exist(w_nm_atribute) then
                
                    for j in 1..w_tmp_template_json.count loop
                        if w_tmp_template_json.get(j).get_string like '%(remover)%' then
                            w_nm_atribute := lower(w_o_template_json.get(i).mapname);
                            if (r_o_json.exist(w_nm_atribute)) then
                                w_tmp_json := json(r_o_json.get(w_nm_atribute));
                                w_nm_atribute := lower(w_tmp_template_json.get(j).mapname);
                                if w_tmp_json.exist(w_nm_atribute) then
                                    w_tmp_json.remove(w_nm_atribute);
                                    w_nm_atribute := lower(w_o_template_json.get(i).mapname);
                                    r_o_json.remove(w_nm_atribute);
                                    r_o_json.put(w_nm_atribute, w_tmp_json, 1);
                                end if;
                            end if;
                        elsif (w_tmp_template_json.get(j).typeval = 2) then
                            w_tmp_template_list := pljson_list(w_tmp_template_json.get(j));
                            w_tmp_json := json(r_o_json.get(w_nm_atribute));
                            if (w_tmp_json.exist(lower(w_tmp_template_json.get(j).mapname))) then
                                w_tmp_list := pljson_list(w_tmp_json.get(lower(w_tmp_template_json.get(j).mapname)));
                                for j in 1..w_tmp_list.count loop
                                    w_tmp_json := util_remove_property(json(w_tmp_list.get(j)), json(w_tmp_template_list.get(1)));
                                    w_tmp_list.remove(j);
                                    w_tmp_list.append(w_tmp_json.to_json_value,j);
                                end loop;
                                w_tmp_json := pljson(r_o_json.get(w_nm_atribute));
                                w_tmp_json.remove(lower(w_tmp_template_json.get(j).mapname));
                                w_tmp_json.put(lower(w_tmp_template_json.get(j).mapname), w_tmp_list, j);
                                r_o_json.remove(w_nm_atribute);
                                r_o_json.put(w_nm_atribute, w_tmp_json);
                            end if;
                        end if;
                    end loop;
                end if;
            elsif w_o_template_json.get(i).typeval = 2 then
                w_tmp_template_list := pljson_list(w_o_template_json.get(i));
                w_tmp_json := pljson(r_o_json.get(w_nm_atribute));
                
                if (w_tmp_json.exist(lower(w_tmp_template_json.get(i).mapname))) then
                    w_tmp_list := pljson_list(w_tmp_json.get(lower(w_tmp_template_json.get(i).mapname)));
                    for j in 1..w_tmp_list.count loop
                        w_tmp_json := util_remove_property(pljson(w_tmp_list.get(i)), pljson(w_tmp_template_list.get(1)));
                        w_tmp_list.remove(i);
                        w_tmp_list.append(w_tmp_json.to_json_value,i);
                    end loop;
                    
                    w_tmp_json := pljson(r_o_json.get(w_nm_atribute));
                    w_tmp_json.remove(lower(w_tmp_template_json.get(i).mapname));
                    w_tmp_json.put(lower(w_tmp_template_json.get(i).mapname), w_tmp_list, i);
                    r_o_json.remove(w_nm_atribute);
                    r_o_json.put(w_nm_atribute, w_tmp_json);
                end if;
            else
                if w_o_template_json.get(i).get_string like '%(remover)%' then
                    r_o_json.remove(lower(w_o_template_json.get(i).mapname));
                end if;
            end if;
        end loop;
        return r_o_json;
    end util_remove_property;
    
/**
    Extrair dados do template que estão marcados com (requerido),
    (chave) e (atualizar), a função utiliza uma dessas opções para compor
    os dados de retorno especificos para cada tipo.
    
    @param  p_method    função a ser tratada com as tags <valor>
    @param  p_template  template padrão da entidade atual
    @param  p_o_json    objeto json contendo o json da atual entidade
    @param  r_funcion   <b>retorna</b> a função com as tags trocadas pelos valores do p_o_json (requerido)
    @param  r_keys      <b>retorna</b> as chaves retiradas do p_o_json caso exista (chave)
    @param  r_set       <b>retorna</b> os campos a ser atualizado na tabela (atualizar)
*/
    procedure util_extract_from_template(r_funcion out varchar2, r_keys out varchar2, r_set out varchar2, p_method in varchar2, p_template in varchar2, p_o_json in pljson, p_entity in varchar2) is
        w_funcao          varchar2(300);
        w_o_json          pljson;
        w_o_json_value    pljson_value;
        w_o_json_template pljson;
        w_vl_update       varchar2(200);
        w_tmp_set         varchar2(200);
        function util_replace(p_function varchar2, p_what varchar2, p_replace varchar2) return varchar2 is
        begin
            return replace(p_function, p_what, p_replace);
        end;
        
        
        function get_update(p_set varchar2, p_atributo varchar2, p_valor varchar2) return varchar2 is
            
        begin
            if p_set is null then 
                return p_atributo || ' = ' || p_valor || ' ';
            else
                return ', ' || p_atributo || ' = ' || p_valor || ' ';
            end if;
            return null;
        end;
        
        procedure set_r_set(p_pljson pljson, p_template_pljson pljson) is
            v_pljson_value pljson_value;
        begin
            for i in 1..p_template_pljson.count loop
                v_pljson_value := p_template_pljson.get(i);
                if v_pljson_value.get_type = 'object' then
--                    v_pljson_value.print;
                    set_r_set(pljson(v_pljson_value), pljson(p_template_pljson.get(i)));
                end if;
                if p_template_pljson.get(upper(v_pljson_value.mapname)).get_string like '%(atualizar)%' then
                    if instr(v_pljson_value.str, '<type:number>') > 0 then
                        w_vl_update := '<'||upper(v_pljson_value.mapname)||'>';
                    elsif instr(v_pljson_value.str, '<type:date>') > 0 then
                        w_vl_update := 'sysdate';
                    else
                        w_vl_update := '''<'||upper(v_pljson_value.mapname)||'>''';
                    end if;
                    r_set := r_set || get_update(r_set, v_pljson_value.mapname, w_vl_update);
                    w_vl_update := null;
                end if;
            end loop;
        end;
        
        procedure set_r_keys_and_function(p_pljson pljson, p_template_pljson pljson) is
            v_pljson_value pljson_value;
        begin
            
            for i in 1..p_pljson.count loop
                v_pljson_value := p_pljson.get(i);
                if v_pljson_value.get_type = 'object' then
--                    v_pljson_value.print;
                    set_r_keys_and_function(pljson(v_pljson_value), pljson(p_template_pljson.get(i)));
                end if;
                if p_template_pljson.exist(upper(v_pljson_value.mapname)) then
                    p_template_pljson.get(upper(v_pljson_value.mapname)).print;
                    if p_template_pljson.get(upper(v_pljson_value.mapname)).get_string like '%(requerido)%' then
                        if v_pljson_value.typeval = 3 then
                            w_funcao := util_replace(w_funcao, lower('<'||v_pljson_value.mapname||'>'), v_pljson_value.str);
                        elsif v_pljson_value.typeval = 4 then
                            w_funcao := util_replace(w_funcao, lower('<'||v_pljson_value.mapname||'>'), to_char(v_pljson_value.num));
                        elsif v_pljson_value.typeval = 6 then
                            w_funcao := util_replace(w_funcao, lower('<'||v_pljson_value.mapname||'>'), v_pljson_value.get_null);
                        end if;
                    end if;
                    
                    if p_template_pljson.get(upper(v_pljson_value.mapname)).get_string like '%(chave)%' then
                        if v_pljson_value.typeval = 3 then
                            if r_keys is null then 
                                r_keys := r_keys || v_pljson_value.mapname || ' = ''' || v_pljson_value.str || ''' ';
                            else
                                r_keys := r_keys || 'and ' || v_pljson_value.mapname || ' = ''' || v_pljson_value.str || ''' ';
                            end if;
                        elsif v_pljson_value.typeval = 4 then
                            if r_keys is null then 
                                r_keys := r_keys || v_pljson_value.mapname || ' = ''' || v_pljson_value.num  || ''' ';
                            else
                                r_keys := r_keys || 'and ' || v_pljson_value.mapname || ' = ''' || v_pljson_value.num  || ''' ';
                            end if;
                        end if;
                    end if;
                end if;
            end loop;
        end;
    begin
        w_funcao := p_method;
        w_o_json_template := pljson(p_template);
        
        if p_entity is not null then
            w_o_json_template := pljson(w_o_json_template.get(upper(p_entity)));
        end if;
--        w_o_json_template.print;
        w_o_json := p_o_json;
--        w_o_json.print;
        --monta o "set" do update
        set_r_set(w_o_json, w_o_json_template);
--        w_o_json.print;
--        w_o_json_template.print;
        set_r_keys_and_function(w_o_json, w_o_json_template);
        r_funcion := w_funcao;
    end util_extract_from_template; 
    
    function util_convert_ascii_to_hex(p_text varchar2) return varchar2 is
        w_text varchar2(1000);
        elem varchar2(10);
        indice integer;
    begin
--        indice := 1;
--        elem := substr(p_text, indice,1);
--        while elem is not null loop
--            if elem = '@' then
--                w_text := w_text || '%' ||rawtohex( utl_raw.cast_to_raw(elem));
--            else
--                w_text := w_text || elem;    
--            end if;
--            indice := indice + 1;
--            elem := substr(p_text, indice,1);
--        end loop;
        if instr(p_text, '@') > 0 then
            w_text := replace(p_text, '@', '%40');
        else
            w_text := p_text;
        end if;
        return w_text;
    end;
    
/**
    Converter string data vinda do canvas para date.
    
    @param  p_str_date  string data a ser convertido.
    @return date convertido.
*/
    function util_str_to_date(p_str_date varchar2) return date is
        w_data varchar2(50);
    begin
        
        w_data := replace(p_str_date, '"', '');
        if w_data is not null and w_data != '' then
            return to_date(translate(w_data, 'TZ','  '), 'rrrr-mm-dd hh24:mi:ss ');
        else
            return null;
        end if;
    end;
    /****************************Termino Utils*********************************/
    
    /*****************************Inicio Genérico******************************/    
    
/*
    Executar comandos OS via JAVA (Host_command3), 
    nesse caso foi criado um script (w_script) que realiza a requisição, 
    que retorna em string o resultado.
    
    @param  p_action    ação a ser requisitado (GET, POST, PUT, etc)
    @param  p_method    metodo da chamada da requisição
    @param  p_json      quando há persistência deve informar
    @param  r_json      <b>retorna</b> o resultado da requisição, ler documentação para mais detalhes
    @param  r_msg       <b>retorna</b> as informações para o log
    
*/
    procedure execute_hostcommand(p_action in varchar2, p_method in varchar2, p_json in clob default null, r_json out clob, r_msg out clob) is
        l_output  dbms_output.chararr;
        l_lines   integer := 1000000;
        l_tmp_lob clob;
            
        function eliminar_sujeira(t clob) return clob is
        begin
            --dbms_output.put_line('t==='||t);
            if t like 'Process out%' 
--            and t not like '%Erro%' 
            and t not like '%Sintaxe%'
            and t not like '%informado deve ser GET ou POSTthen%' 
            and t not like '%Runtime Error%' then
                return replace(t, 'Process out :', '');
            end if;
            return empty_clob();
        end;
        
        
    begin
        dbms_output.disable;
        dbms_output.enable(1000000);
        dbms_java.set_output(1000000);
        --host_command3('/home/oracle/integracaoCanvas,GET,users?page1');
        if p_json is null then
            host_command3(script||','||p_action||','||p_method);
        else--TRANSLATE (col_name, 'x'||CHR(10)||CHR(13), 'x')
            host_command3(script||','||p_action||','||p_method||',<json>'||replace(TRANSLATE(p_json,  'x'||chr(10)||chr(13), 'x'), 'null', '""')||'</json>');--p_json TODO
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
            end if;
        end loop;
    end execute_hostcommand;
    
/**
    Buscar todos os registros conforme metodo utilizado
    (Serviço paginado)
    
    @param  p_metodo    metodo para realizar a requisição (users, courses, sections, etc) verificar documentação
    @param  r_msg       <b>retorna</b> as informações para o log
    
    @return string, formato em json
    
*/
    function dao_find_all(p_metodo varchar2, p_parametros varchar2 default null, r_msg out clob) return clob is
--        w_json varchar2(32767);
        w_json clob;
        w_msg  clob;
    begin
        execute_hostcommand(p_action => 'GET', p_method => p_metodo||p_parametros, r_json => w_json, r_msg => w_msg);
        r_msg := r_msg || chr(10) || w_msg;
        return w_json;
    end dao_find_all;
    
/**
    Retornar lista de lista de valores
*/
    function get_valores(p_resposta_js clob) return r_r_valores is
        
        indice        integer := 1;
        indice2       integer := 1;
        l_is_erro     boolean;
        retorno       r_valores;
        retorno2      r_r_valores;
        v_valor       r_valor;
        w_json        pljson;
        w_resposta_js clob;
        
        procedure set_values(p_json pljson_value) is
        begin
            v_valor.atributo := p_json.mapname;
            v_valor.valor := p_json.to_char;
            v_valor.isErro := l_is_erro;
            retorno(indice) := v_valor;
            indice := indice + 1;
        end;
        
        procedure get_response (p_json_value pljson_value) is
            --typeval number(1), /* 1 = object, 2 = array, 3 = string, 4 = number, 5 = bool, 6 = null */
            l_json      pljson;
            l_json_list pljson_list;
        begin
            
            if (p_json_value.typeval = 1) then
                l_json := pljson(p_json_value.to_char);
--                p('novo json:');
--                l_json.print(false); 
                for i in 1..l_json.count loop
                    get_response (l_json.get(i));
                end loop;
                retorno2(indice2) := retorno;
                indice2 := indice2 + 1;
            elsif (p_json_value.typeval = 2) then
                l_json_list := pljson_list(p_json_value.to_char);
                for i in 1..l_json_list.count loop
                    get_response (l_json_list.get(i));
                end loop;
            elsif (p_json_value.typeval in (3, 4, 5)) then
                set_values(p_json_value);
            else
                null;
            end if;
        end;
    begin
--        tmp_json := '{"errors":{"user":{"pseudonyms":[{"attribute":"pseudonyms","type":"invalid","message":"invalid"}]},"pseudonym":{"unique_id":[{"attribute":"unique_id","type":"taken","message":"ID já em uso para esta conta e fornecedor de autenticação"}]},"observee":{}}}';
--        tmp_json := '{"id":"113", "login":"daniel.teste"}'; 
        
--        w_resposta_js := p_resposta_js;
        w_resposta_js := '{"valores":'||p_resposta_js||'}';
--        if substr(w_resposta_js, 1, 1) = '[' then
--            w_resposta_js := '{"valores":'||p_resposta_js||'}';
--        end if;
        if w_resposta_js is not null then
            w_json := pljson(w_resposta_js);
            
            if (w_json.exist('errors')) then
                l_is_erro := true;
            else
                l_is_erro := false;
            end if;
            
            for i in 1..w_json.count loop
                get_response(w_json.get(i));
            end loop;
        end if;
        return retorno2;
    
    end get_valores;
    
    
/**
    <p>
    Retornar lista de valores(r_valores) declarado no pacote spec
    conforme o parametro que deve ser no formato json.
    
    <h4>Funções internas:<h4>
        <ul>
            <li>
                <b>set_values:</b> seta os valores na lista de retorno, obtidos do json
                <p><b>Parametros;</b>
                    <ul>
                        <li>
                            p_json: objeto json_value que contém os dados a serem extraidos para add na lista
                        </li>
                    </ul>
                </p>
            </li>
            <li>
                <b>get_response:</b> verifica o tipo do valor, se diferente de objeto ou lista, chama a função 
                                     set_values para setar os dados, se não, realiza chamada recursiva ate 
                                     encontrar a resposta.
                <p><b>Parametro;</b>
                    <ul>
                        <li>
                            p_json_value: conteúdo da resposta
                        </li>
                    </ul>
                </p>
            </li>
        <ul>
    </p>
    
    @param  p_resposta_js   string em formato json.
    
    @return r_valores   lista de record do tipo r_valor declarado no pacote spec.
        
*/
    function get_result(p_resposta_js clob) return r_dados is
        
        indice        integer := 1;
        l_is_erro     boolean;
--        retorno   r_valores;
        v_valor       r_valor;
        w_json        pljson;
        w_resposta_js clob;
        dados         r_dados;
        
        procedure set_values(p_json pljson_value) is
        begin
            v_valor.atributo := p_json.mapname;
            v_valor.valor := p_json.to_char;
            v_valor.isErro := l_is_erro;
--            retorno(indice) := v_valor;
            dados(v_valor.atributo) := v_valor;
            indice := indice + 1;
        end;
        
        procedure get_response (p_json_value pljson_value) is
            --typeval number(1), /* 1 = object, 2 = array, 3 = string, 4 = number, 5 = bool, 6 = null */
            l_json      pljson;
            l_json_list pljson_list;
        begin
            
            if (p_json_value.typeval = 1) then
                l_json := pljson(p_json_value.to_char); 
                for i in 1..l_json.count loop
                    get_response (l_json.get(i));
                end loop;
            elsif (p_json_value.typeval = 2) then
                l_json_list := pljson_list(p_json_value.to_char);
                for i in 1..l_json_list.count loop
                    get_response (l_json_list.get(i));
                end loop;
            elsif (p_json_value.typeval in (3, 4, 5)) then
                set_values(p_json_value);
            else
                null;
            end if;
        end;
    begin
--        tmp_json := '{"errors":{"user":{"pseudonyms":[{"attribute":"pseudonyms","type":"invalid","message":"invalid"}]},"pseudonym":{"unique_id":[{"attribute":"unique_id","type":"taken","message":"ID já em uso para esta conta e fornecedor de autenticação"}]},"observee":{}}}';
--        tmp_json := '{"id":"113", "login":"daniel.teste"}'; 
--        plob(p_resposta_js);
        w_resposta_js := p_resposta_js;
        if substr(w_resposta_js, 1, 1) = '[' then
            w_resposta_js := '{"valores":'||p_resposta_js||'}';
        end if;
        if w_resposta_js is not null then
            w_json := pljson(w_resposta_js);
            if (w_json.exist('errors')) then
                l_is_erro := true;
            else
                l_is_erro := false;
            end if;
            for i in 1..w_json.count loop
                get_response(w_json.get(i));
            end loop;
        end if;
        return dados;
    
    end get_result;
    
/**
    <p>
        Buscar inscrições por usuário: está rotina irá buscar todas as inscrições de um usuário pelo 
        parâmetro <b>p_sis_user_id</b>.
    </p>
        
        @param  p_sis_user_id   sis_id do usuário
        @return objeto json caso exista inscrições do usuário informado.
*/
    function get_inscrioes_by_user(p_sis_user_id varchar2) return pljson is
        w_msg       clob;
        w_resposta  clob;
    begin
        w_resposta := dao_find_all(p_metodo => 'users/sis_user_id:'||p_sis_user_id||'/enrollments', r_msg => w_msg);
        if w_resposta is not null and UPPER(w_resposta) not like 'ERRORS' AND UPPER(w_resposta) not like 'EXCEPTION' then
            return new pljson(w_resposta);
        end if;
        
        return null;
    
    end;

    
/**
    Requisição de atualização "PUT"
    
    @param  p_json      string json a ser enviado.
    @param  p_method    requisição.
    @param  r_msg       <b>retorna</b> o log.
    
    @return r_valores   resultado da requisição.
    
*/
    function dao_update (p_json varchar2, p_method varchar2, r_msg out clob) return clob as
        w_resposta clob;
        w_msg clob;
    begin
        r_msg := r_msg || chr(10) || 'Iniciar requisição';
        r_msg := r_msg || chr(10) || 'Método: PUT';
        r_msg := r_msg || chr(10) || 'Função: '||p_method;
        execute_hostcommand(p_action => 'PUT', p_method => p_method, p_json => p_json, r_json => w_resposta, r_msg =>  w_msg);
        r_msg := r_msg || chr(10) || w_msg;
        r_msg := r_msg || chr(10) || 'Resposta da requisição: '|| w_resposta;
--        return get_result(w_resposta);
        return w_resposta;
    end dao_update;
    
/**
    <p>
        Atualizar Tabela CANVAS_USUARIOS pelo canvas_id.
    </p>
    <pre>
        FULL_NAME           1   - VARCHAR2 (100 Byte)
        SHORT_NAME          2   - VARCHAR2 (100 Byte)
        SORTABLE_NAME       3   - VARCHAR2 (100 Byte)
        EMAIL               4   - VARCHAR2 (100 Byte)
        LOGIN               5   - VARCHAR2 (14 Byte)
        PASSWORD            6   - VARCHAR2 (8 Byte)
        SIS_USER_ID         7   - VARCHAR2 (40 Byte)
        AUTH_PROVIDER_ID    8   - CHAR     (1 Byte)
        DT_INCL             9   - DATE
        DT_UPDT             10  - DATE
        CANVAS_ID           11  - VARCHAR2 (100 Byte)
    </pre>

    
    @param  p_usuario   dados da tabela preenchido para atualizar (canvas_usuarios%rowtype).
    @return retorna true caso não ocorra nenhum erro senão false,

*/
    function dao_update_table_user(p_usuario canvas_usuarios%rowtype) return boolean is
        c number;
        n number;
    begin
        c := dbms_sql.open_cursor;

        dbms_sql.parse(c, 
--        ROW = p_usuario
'UPDATE canvas_users '||
--   'set ROW = :pUSUARIO '||
   'set FULL_NAME = :pFULL_NAME '||
      ',SHORT_NAME = :pSHORT_NAME '||
      ',SORTABLE_NAME = : pSORTABLE_NAME '||
      ',EMAIL = :pEMAIL '||
      ',LOGIN = :pLOGIN '||
      ',PASSWORD = :pPASSWORD '||
      ',SIS_USER_ID = :pSIS_USER_ID '||
      ',AUTH_PROVIDER_ID = :pAUTH_PROVIDER_ID '||
      ',DT_INCL = :pDT_INCL '||
      ',DT_UPDT = :pDT_UPDT '||
    'where  canvas_id = :pCANVAS_ID'
                    , dbms_sql.native);
        dbms_sql.bind_variable(c, 'pFULL_NAME',         p_usuario.FULL_NAME);
        dbms_sql.bind_variable(c, 'pSHORT_NAME',        p_usuario.SHORT_NAME);
        dbms_sql.bind_variable(c, 'pSORTABLE_NAME',     p_usuario.SORTABLE_NAME);
        dbms_sql.bind_variable(c, 'pEMAIL',             p_usuario.EMAIL);
        dbms_sql.bind_variable(c, 'pLOGIN',             p_usuario.LOGIN);
        dbms_sql.bind_variable(c, 'pPASSWORD',          p_usuario.PASSWORD);
        dbms_sql.bind_variable(c, 'pSIS_USER_ID',       p_usuario.SIS_USER_ID);
        dbms_sql.bind_variable(c, 'pAUTH_PROVIDER_ID',  p_usuario.AUTH_PROVIDER_ID);
        dbms_sql.bind_variable(c, 'pDT_INCL',           p_usuario.DT_INCL);
        dbms_sql.bind_variable(c, 'pDT_UPDT',           p_usuario.DT_UPDT);
        dbms_sql.bind_variable(c, 'pCANVAS_ID',         p_usuario.CANVAS_ID);
        n := dbms_sql.execute(c); 
        util.p('Qtd linhas atualizadas: ' || to_char (n), is_debug);
--        dbms_sql.variable_value(c, 'bnd3', r);-- get value of outbind variable
        dbms_sql.close_cursor(c);
        return true;
        exception 
            when others then 
                if dbms_sql.is_open(c) then
                    dbms_sql.close_cursor(c);
                end if;
--                RAISE;
                return false;
    end;

/**
    <p>
    Função que atualizar a tabela <b>canvas_notas</b>, com dados do parâmetro.
    </p>
    @param  p_nota  dados da nota.
    @return retorna verdadeiro quando atualizado.
*/
    function dao_update_table_nota(p_nota canvas_notas%rowtype) return boolean is
        
    begin
        update canvas_notas
            set row = p_nota
--           set TYPE                = p_nota.TYPE           
--              ,LAST_ACTIVITY_AT  = p_nota.LAST_ACTIVITY_AT
--              ,CURRENT_SCORE   = p_nota.CURRENT_SCORE  
--              ,FINAL_SCORE         = p_nota.FINAL_SCORE    
--              ,CURRENT_GRADE   = p_nota.CURRENT_GRADE  
--              ,FINAL_GRADE         = p_nota.FINAL_GRADE    
--              ,STATE           = p_nota.STATE
         where SIS_SECTION_ID = p_nota.SIS_SECTION_ID
           and SIS_COURSE_ID  = p_nota.SIS_COURSE_ID    
           and SIS_USER_ID    = p_nota.SIS_USER_ID
           and CANVAS_ID      = p_nota.CANVAS_ID;
           
        if sql%rowcount > 0 then
            return true;
        else
            return false;
        end if;
--        exception 
--            when others then
--                return false;
    end;
    
/**
    <p>
    Função que atualizar a tabela <b>canvas_notas</b>, com dados do parâmetro.
    </p>
    @param  p_nota  dados da nota.
    @return retorna verdadeiro quando atualizado.
*/
    function dao_insert_table_nota(p_nota canvas_notas%rowtype) return boolean is
        
    begin
        insert into canvas_notas values p_nota;
        if sql%rowcount > 0 then
            commit;
            return true;
        else
            return false;
        end if;
--        exception 
--            when others then
--                return false;
    end;
    
/**
    <p>
    Salvar via requisição (p_method).</br>

    Exemplo de usuario, seguir a estrutura definida nos templates
<pre>

{
    "user": {
            "full_name": "Daniel Teste",
            "short_name": "Daniel",
            "sortable_name": "Daniel Teste",
            "email": "daniel.teste@noreply.com",
            "login": "daniel.teste",
            "password": "123qwe",
            "sis_user_id": "danieltestedkm",
            "auth_provider_id": ""
        }
}
</pre>
    </p>
    
    @param  p_json      formato json a ser enviado
    @param  p_method    requisição.
    @param  is_batch    em lote.
    @param  r_msg       <b>retorna</b> o log.
    
    @return resposta da requisição.
*/
    function dao_save(p_json varchar2, p_method varchar2, r_msg out clob) return clob is
        
        w_resposta clob;        
        w_msg clob;
    begin

        r_msg := r_msg || chr(10) || 'Iniciar requisição';
        r_msg := r_msg || chr(10) || 'Método: POST';
        r_msg := r_msg || chr(10) || 'Função: '||p_method;
        execute_hostcommand(p_action => 'POST', p_method => p_method, p_json => p_json, r_json => w_resposta, r_msg => w_msg);
        r_msg := r_msg || chr(10) || w_msg;
        r_msg := r_msg || chr(10) || 'Resposta da requisição: '|| w_resposta;
        return w_resposta;
        
    end dao_save;
    
/*
    Chamada do metodo delete.
    
    @param  p_json      string json a ser enviado.
    @param  p_method    o metodo nesse caso é a função utilizada na requisição.
    @param  r_msg       <b>retorna</b> o log.
    
    @return   resultado da requisição.
*/
    function dao_delete (p_method varchar2, r_msg out clob) return clob as
        w_resposta clob;
        w_msg clob;
    begin
        r_msg := r_msg || chr(10) || 'Iniciar requisição';
        r_msg := r_msg || chr(10) || 'Método: DELETE';
        r_msg := r_msg || chr(10) || 'Função: '||p_method;
        execute_hostcommand(p_action => 'DELETE', p_method => p_method, p_json => null, r_json => w_resposta, r_msg =>  w_msg);
        r_msg := r_msg || chr(10) || w_msg;
        r_msg := r_msg || chr(10) || 'Resposta da requisição: '|| w_resposta;
--        return get_result(w_resposta);
        return w_resposta;
    end dao_delete;
    
/**
    Padronizar a chamada da requisição para criar/salvar os dados no canvas.
    
    @param  p_json      json a ser inserido/criado/salvo.
    @param  p_method    metodo utilizado para realizar a criação.
    @param  p_is_batch  em lote?.
    @param  p_r_msg     <b>retorna</b> o log.
    
    @return lista de r_valor (se encontra no spec desse pacote).
    
*/
    function call_request_save(p_json clob, p_method varchar2, is_batch boolean, r_msg out clob) return clob is
    
        w_msg        clob;    
        w_json       clob;
        w_valores    r_valores;
        w_resposta   clob;
    begin
    
        w_json := p_json;
        r_msg := r_msg || chr(10) || 'Inserir: '|| w_json;
        w_resposta := dao_save(w_json, p_method, w_msg);
        r_msg := r_msg || chr(10) || w_msg;
        return w_resposta;
--        w_valores := dao_save(w_json, p_method, is_batch, w_msg);
--        r_msg := r_msg || chr(10) || w_msg;
--        util_show_result(w_valores, w_msg);
--        r_msg := r_msg || chr(10) || w_msg;
--        return w_valores;
    exception
        when others then
            r_msg := r_msg || chr(10) || 'Inicio Erro;';
            r_msg := r_msg || chr(10) || 'Ao chamar a requisição de inserção';
            r_msg := r_msg || chr(10) || w_msg;
            r_msg := r_msg || chr(10) || util.get_erro;
            r_msg := r_msg || chr(10) || 'Fim Erro';
            return null;
    end;
    
/**
    Padronizar a chamada da requisição para atualizar os dados no canvas
    
    @param  p_json      json a ser atualizado
    @param  p_method    metodo utilizado para realizar a atualização
    @param  p_r_msg     <b>retorna</b> o log
    
    @return boolean caso a requisição for realizado com sucesso retorna true...
*/
    function call_request_update(p_json varchar2, p_method varchar2, r_msg out clob) return clob as

        w_msg        clob;
        w_json       clob;
        w_resposta   clob;
        w_valores    r_valores;
--        w_dados      r_dados;
        js_resposta  pljson;
    begin
        w_json := p_json;
        r_msg := r_msg || chr(10) || 'Atualizar: '|| w_json;
--        w_valores := dao_update(w_json, p_method, w_msg);
        w_resposta := dao_update(w_json, p_method, w_msg);
        r_msg := r_msg || chr(10) || w_msg;
        return w_resposta;     
--        js_resposta := pljson(w_resposta);
--        r_msg := r_msg || chr(10) || 'Tamanho r_valores:'||js_resposta.count;
--        if js_resposta.count > 0 then
----            util_show_result(js_resposta, w_msg);
----            r_msg := r_msg || chr(10) || w_msg;
--            if upper(w_msg) not like '%ERRO%' then
--                return true;
--            else
--                return false;
--            end if;
--        else
--            return true;
--        end if;
    exception
        when others then
            r_msg := r_msg || chr(10) || 'Inicio Erro;';
            r_msg := r_msg || chr(10) || 'Ao chamar a requisição de atualização do '||p_method||' (call_request_update)';
            r_msg := r_msg || chr(10) || util.get_erro;
            r_msg := r_msg || chr(10) || 'Fim Erro';
            return w_resposta;
    end call_request_update;
    
/*
    Padronizar a chamada da requisição para os metodos do tipo delete.
    
    @param  p_json      json
    @param  p_method    função utilizada para requisição do delete
    @param  p_r_msg     <b>retorna</b> o log
    
    @return r_valores  lista de r_valor (se encontra no spec desse pacote)
*/
    function call_request_delete(p_method varchar2, r_msg out clob) return clob is
        w_msg        clob;
        w_resposta   clob;
--        w_valores    r_valores;
        js_reposta   pljson;
    begin
--        r_msg := r_msg || chr(10) || 'Metodo deletar: '|| p_method;
        w_resposta := dao_delete(p_method, w_msg);
        r_msg := r_msg || chr(10) || w_msg;
        return w_resposta; 
--        js_reposta := pljson(dao_delete(p_method, w_msg));
--        r_msg := r_msg || chr(10) || w_msg;
--        if lower(w_msg) like '%erro%' then
--            return false;
--        else
--            return true;
--        end if;
    exception
        when others then
            r_msg := r_msg || chr(10) || 'Inicio Erro;';
            r_msg := r_msg || chr(10) || 'Ao chamar o metodo delete';
            r_msg := r_msg || chr(10) || w_msg;
            r_msg := r_msg || chr(10) || util.get_erro;
            r_msg := r_msg || chr(10) || 'Fim Erro';
            return w_resposta;
    end call_request_delete;
    /****************************Termino Genérico******************************/
    
    
    /****************************Inicio Serviços*******************************/
/**
    <p>
    Enquanto estiver generico, senão devo retornar a reposta para o controller de 
    cada entidade e tratar para realizar a atualização, utilizado com base 
    na procedure service_update_table_user.
    </p>
    
    <p>
        Atualiza as tabelas da base Oracle (canvas_*), com base na resposta da 
    requisição <em>@p_o_json_resp</em>, os dois parâmetros, irá vir construído
    com base nos templates, aqui iremos ainda verificar se existe tags para serem
    substituidos, com os dados vindo da resposta. Caso necessite atualizar as tabelas 
    com base nos dados vindos das respostas das requisições.
    </p>
    
    @param  p_o_json_resp   resposta da requisição, Objeto JSON
    @param  p_key           são as condições para atualização, where "p_key"
    @param  p_update        quais campos serão atualizados, set "p_update"
    
*/
    procedure service_updt_db_oracle(p_nm_table varchar2, p_o_json_resp pljson default null, p_key varchar2, p_update varchar2, r_msg out clob) is
        l_update     varchar2(200);
        l_chave      varchar2(200);
        l_sql        varchar2(2000);
        w_msg        clob;
    begin
        l_chave := p_key;
        l_update := p_update;
        if p_o_json_resp is not null then
            for i in 1..p_o_json_resp.count loop
                if upper(p_o_json_resp.get(i).mapname) = 'ID' then
                    if p_o_json_resp.get(i).typeval = 3 then
                        l_update := replace(l_update, '<CANVAS_ID>', p_o_json_resp.get(i).str);
                    elsif p_o_json_resp.get(i).typeval = 4 then
                        l_update := replace(l_update, '<CANVAS_ID>', to_char(p_o_json_resp.get(i).num));
                    end if;
                end if;
                if p_o_json_resp.get(i).typeval = 3 then
                    l_update := replace(l_update, '<'||upper(p_o_json_resp.get(i).mapname)||'>', p_o_json_resp.get(i).str);
                    l_chave := replace(l_chave, '<'||lower(p_o_json_resp.get(i).mapname)||'>', p_o_json_resp.get(i).str);
                elsif p_o_json_resp.get(i).typeval = 4 then
                    l_update := replace(l_update, '<'||upper(p_o_json_resp.get(i).mapname)||'>', to_char(p_o_json_resp.get(i).num));
                    l_chave := replace(l_chave, '<'||lower(p_o_json_resp.get(i).mapname)||'>', to_char(p_o_json_resp.get(i).num));
                end if;
    --                if not( instr(l_update, '<') > 0 and instr(l_chave, '<') > 0 ) then
    --                    is_update := true;
    --                    exit;
    --                end if;
            end loop;
            
            if p_o_json_resp.get('error') is not null then
                if p_o_json_resp.get('error').str =  'enrollment not inactive' then
                    if l_update like '%<STATE>%' then
                        l_update := replace(l_update, '<STATE>', 'active');
                    end if;
                end if;
            end if;
        end if;
        
        
                
--        if is_update then
            l_sql := 'update '||p_nm_table||' set '||l_update||' where '||replace(l_chave, '%40', '@'); --w_nm_primary_key||' = '''||w_id||''''; --to_date('''||to_char(sysdate, 'rrrr-mm-dd HH24:MI:SS')||''', ''rrrr-mm-dd HH24:MI:SS'')
            r_msg := r_msg || chr(10) || l_sql;
            w_msg := '';
            if not(util_execute_sql(l_sql, w_msg)) then
                r_msg := r_msg || chr(10) || w_msg;
                raise e_table_not_update;
            else
                r_msg := r_msg || chr(10) || w_msg;
                r_msg := r_msg || chr(10) || 'Atualizou '||p_nm_table||' ('||l_chave||')' || chr(10);
                commit;
            end if;
--        end if;
        exception
            when e_table_not_update then
                r_msg := r_msg || chr(10) || replace(msg_e_table_not_update, 'dado', '');
            when others then
                r_msg := r_msg || chr(10) || 'Inicio Erro (service_updt_db_oracle)';
                r_msg := r_msg || chr(10) || util.get_erro;
                r_msg := r_msg || chr(10) || 'Fim Erro (service_updt_db_oracle)';
    end service_updt_db_oracle;
    
/**
    <p>
    Montar <em>insert</em> conforme o json <b>"@p_json"</b> e executar para 
    persistir.
    </p>
    
    @param  p_nm_table  nome da tabela;
    @param  p_json      json de referencia;
    @return r_msg       log;         
*/
    procedure service_insrt_db_oracle(p_nm_table varchar2, p_json pljson, r_msg out clob) is
        w_msg clob;
        w_nm_atributos varchar2(1000) := '(';
        w_values       varchar2(2000) := '(';
        v_insert varchar2(2000);
    /**
        <p>
        Retorna o valor do <em>json_value</em>.
        </p>
        @param  p_value     objeto pljson_value;
        @param  p_virgula   separador (vírgula ou parentese);
        @return valor do json
    */    
        function get_value (p_value pljson_value, p_virgula varchar2) return varchar2 is
        begin
            if p_value.get_type = 'string' then
                return ''''||p_value.get_string||''''||p_virgula;
            elsif p_value.get_type = 'number' then
                return p_value.get_number||p_virgula;
            elsif p_value.get_type = 'bool' then
                if p_value.get_bool then
                    return 'true'||p_virgula;
                else
                    return 'false'||p_virgula;
                end if;
            elsif p_value.get_type = 'null' then
                return 'null'||p_virgula;
            end if;
        end;
    begin
        v_insert := 'insert into '||p_nm_table;
        for i in 1..p_json.count loop
            declare
                w_value pljson_value;
            begin
                w_value := p_json.get(i);
                if i = p_json.count then
                    w_nm_atributos := w_nm_atributos||w_value.mapname||')';
                    w_values       := w_values||get_value(w_value, ')');
                else
                    w_nm_atributos := w_nm_atributos||w_value.mapname||',';
                    w_values       := w_values||get_value(w_value, ',');
                end if;
            end;
        
        end loop;
        r_msg := r_msg||chr(10)||'w_nm_atributos:'||w_nm_atributos;
        r_msg := r_msg||chr(10)||'w_values:'||w_values;
        v_insert := v_insert||w_nm_atributos||' values '||w_values;
        r_msg := r_msg||chr(10)||'v_insert:'||v_insert;
        if util_execute_sql(v_insert, w_msg) then
            r_msg := r_msg||chr(10)||w_msg;
            raise e_table_not_update;
        end if;
        exception
            when e_table_not_update then
                r_msg := r_msg || chr(10) || replace(msg_e_table_not_update, 'dado', '');
            when others then
                r_msg := r_msg || chr(10) || 'Inicio Erro (service_insrt_db_oracle)';
                r_msg := r_msg || chr(10) || util.get_erro;
                r_msg := r_msg || chr(10) || 'Fim Erro (service_insrt_db_oracle)';
    end;
    
/**
    Camada de serviço onde intermedia a chamada de requisição 
    de persistência para a "criação" e atualização da p_nm_table
    conforme retorno.
    
    @param  p_json      json a ser enviado.
    @param  p_function  função de chamada da requisição.
    @param  p_key       chaves para atualizar a tabela.
    @param  p_update    o que irá atualizar na tabela.
    @param  is_batch    em lote.
    @param  r_msg       <b>retorna</b> o log.
    
*/
    procedure service_save_request(p_json clob, p_entity varchar2, p_nm_table varchar2, p_method varchar2, p_template varchar2, is_batch boolean, r_msg out clob, is_update boolean default true) is
       
        w_msg         clob;
        w_resposta    clob;
        w_str_json    clob;
        w_o_json_resp pljson;
        w_o_list_resp pljson_list;
        
        w_pljson    pljson;
        w_function  varchar2(200);
        w_chave     varchar2(200);
        w_update    varchar2(200);
        
--        /**
--            Enquanto estiver generico, senão devo retornar a reposta para o controller de 
--            cada entidade e tratar para realizar a atualização, utilizar com base 
--            na procedure service_update_table_user.
--        */
--        procedure atualizar_retorno(p_o_json_resp pljson, p_key varchar2, p_update varchar2) is
--            l_update     varchar2(200);
--            l_chave      varchar2(200);
--            l_sql        varchar2(200);
--            
--        begin
--            l_chave := p_key;
--            l_update := p_update;
--            for i in 1..p_o_json_resp.count loop
--                if upper(p_o_json_resp.get(i).mapname) = 'ID' then
--                    if p_o_json_resp.get(i).typeval = 3 then
--                        l_update := replace(l_update, '<CANVAS_ID>', p_o_json_resp.get(i).str);
--                    elsif p_o_json_resp.get(i).typeval = 4 then
--                        l_update := replace(l_update, '<CANVAS_ID>', to_char(p_o_json_resp.get(i).num));
--                    end if;
--                end if;
--                if p_o_json_resp.get(i).typeval = 3 then
--                    l_update := replace(l_update, '<'||upper(p_o_json_resp.get(i).mapname)||'>', to_char(util.keep_number(p_o_json_resp.get(i).str)));
--                    l_chave := replace(l_chave, '<'||lower(p_o_json_resp.get(i).mapname)||'>', to_char(util.keep_number(p_o_json_resp.get(i).str)));
--                elsif p_o_json_resp.get(i).typeval = 4 then
--                    l_update := replace(l_update, '<'||upper(p_o_json_resp.get(i).mapname)||'>', to_char(p_o_json_resp.get(i).num));
--                    l_chave := replace(l_chave, '<'||lower(p_o_json_resp.get(i).mapname)||'>', to_char(p_o_json_resp.get(i).num));
--                end if;
----                if not( instr(l_update, '<') > 0 and instr(l_chave, '<') > 0 ) then
----                    is_update := true;
----                    exit;
----                end if;
--            end loop; 
--            
--            if is_update then
--                l_sql := 'update '||p_nm_table||' set '||l_update||' where '||replace(l_chave, '%40', '@'); --w_nm_primary_key||' = '''||w_id||''''; --to_date('''||to_char(sysdate, 'rrrr-mm-dd HH24:MI:SS')||''', ''rrrr-mm-dd HH24:MI:SS'')
--                r_msg := r_msg || chr(10) || l_sql;
--                w_msg := '';
--                if not(util_execute_sql(l_sql, w_msg)) then
--                    r_msg := r_msg || chr(10) || w_msg;
--                    raise e_table_not_update;
--                else
--                    r_msg := r_msg || chr(10) || w_msg;
--                    r_msg := r_msg || chr(10) || 'Atualizou '||p_nm_table||' ('||l_chave||')' || chr(10);
--                    commit;
--                end if;
--            end if;
--            exception
--                when e_table_not_update then
--                    r_msg := r_msg || chr(10) || 'Inicio Erro:';
--                    r_msg := r_msg || chr(10) || 'l_sql:'||l_sql;
--                    r_msg := r_msg || chr(10) || UTIL.GET_ERRO;
--                    r_msg := r_msg || chr(10) || 'Fim Erro';
--                when others then
--                    r_msg := r_msg || chr(10) || 'Inicio Erro:';
--                    r_msg := r_msg || chr(10) || util.get_erro;
--                    r_msg := r_msg || chr(10) || 'Fim Erro';
--        end atualizar_retorno;
    begin
--        r_msg := r_msg || chr(10) || 'json:'     || p_json; --TODO remover
--        r_msg := r_msg || chr(10) || 'template:' || p_template; --TODO remover
--        r_msg := r_msg || chr(10) || 'p_method:' || lower(p_method); --TODO remover
        
        w_pljson := pljson(util_all_atribute_to_lower(p_json));
        if p_entity is not null then
            r_msg := r_msg || chr(10) || 'p_entity:' || p_entity; --TODO remover
            util_extract_from_template(w_function, w_chave, w_update, lower(p_method), p_template, pljson(w_pljson.get(p_entity)), p_entity);
        else
            util_extract_from_template(w_function, w_chave, w_update, lower(p_method), p_template, w_pljson, null);
        end if;
        w_pljson := util_remove_property(w_pljson, pljson(p_template));
        w_str_json := w_pljson.to_char(false);
        w_function := util_convert_ascii_to_hex(w_function); --replace @ por %40
        
--        r_msg := r_msg || chr(10) || 'w_function:' || w_function; --TODO remover
--        r_msg := r_msg || chr(10) || 'w_chave:' || w_chave; --TODO remover
--        r_msg := r_msg || chr(10) || 'w_update:' || w_update; --TODO remover
        
        if is_batch then
            w_resposta := call_request_save('{'||w_str_json||'}', w_function, is_batch, w_msg);
            r_msg := r_msg || chr(10) || w_msg;
            if substr(w_resposta, 1,1) = '[' then
                w_o_list_resp := pljson_list(w_resposta);
            else
                w_o_json_resp := pljson(w_resposta);
            end if;
            if upper(w_resposta) not like '%FAULTCODE%' and upper(w_resposta) not like '%ERROR%' and upper(w_resposta) not like '%EXCEPTION%' then
                for i in 1..w_o_list_resp.count loop
                    begin
                        if w_o_json_resp is null then
                            w_o_json_resp := pljson(w_o_list_resp.get(i));
                        end if;
                        if is_update then
                            service_updt_db_oracle(p_nm_table, w_o_json_resp, w_chave, w_update, w_msg);
                            r_msg := r_msg || chr(10) || w_msg;
                        end if;
                    exception
                        when e_table_not_update then
                            r_msg := r_msg || chr(10) || w_msg;
                            r_msg := r_msg || chr(10) || replace(msg_e_table_not_update, 'dado', ' '||p_nm_table);
                        when others then
                            r_msg := r_msg || chr(10) || w_msg;
                            r_msg := r_msg || chr(10) || 'Inicio Erro:';
                            r_msg := r_msg || chr(10) || util.get_erro;
                            r_msg := r_msg || chr(10) || 'Fim Erro';
                    end;
                end loop;
            end if;
        else
--            r_msg := r_msg || chr(10) || 'p_json:'||p_json;
--            r_msg := r_msg || chr(10) || 'w_function:'||w_function;
            w_resposta := call_request_save(w_str_json, w_function, is_batch, w_msg);
            r_msg := r_msg || chr(10) || w_msg;
            if upper(w_resposta) not like '%ERROR%' and upper(w_resposta) not like '%EXCEPTION%' then
                w_o_json_resp := pljson(w_resposta);
                if is_update then
                    service_updt_db_oracle(p_nm_table, w_o_json_resp, w_chave, w_update, w_msg);
                    r_msg := r_msg || chr(10) || w_msg;
                end if;
            end if;
        end if;
        exception 
            when others then
                r_msg := r_msg || chr(10) || w_msg;
                r_msg := r_msg || chr(10) || 'Inicio Erro:';
                r_msg := r_msg || chr(10) || w_msg;
                r_msg := r_msg || chr(10) || 'Resposta: '||w_resposta;
                r_msg := r_msg || chr(10) || util.get_erro;
                r_msg := r_msg || chr(10) || 'Fim Erro';
    end service_save_request;
    
/**
    Camada de serviço onde intermedia a chamada de requisição 
    de persistência para a "atualização" e atualização da p_nm_table
    conforme retorno.
    
    @param  p_json      json a ser enviado
    @param  p_method    função de chamada da requisição
    @param  p_nm_table  nome da tabela a ser atualizado após o envio da requisição
    @param  p_entity    entidade a ser trabalhada
    @param  p_ds_entity descrição da entidade
    @param  p_template  template de referencia do json
    @param  r_msg       <b>retorna</b> o log.
*/
    procedure service_update_request(p_json in clob, p_method in varchar2, p_nm_table in varchar2, p_entity in varchar2, p_ds_entity in varchar2, p_template in varchar2, r_msg out clob) is
        w_o_json      pljson;
        w_o_json_list pljson_list;
        w_json        clob;
        w_msg         clob;
        w_resposta    clob;
        w_sql         varchar2(200);
        w_function    varchar2(200);
        w_chave       varchar2(200);
        w_nm_entity   varchar2(100);
        w_update      varchar2(200);
    begin
        w_o_json := pljson(util_all_atribute_to_lower(p_json));
        if p_entity is not null then
            util_extract_from_template(w_function, w_chave, w_update, lower(p_method), p_template, pljson(w_o_json.get(p_entity)), p_entity);
        else
            util_extract_from_template(w_function, w_chave, w_update, lower(p_method), p_template, w_o_json, w_nm_entity);
        end if;
        w_o_json := util_remove_property(w_o_json, pljson(p_template));
        w_json := w_o_json.to_char(false);
        
        if instr(w_function, '@') > 0 then
            w_function := replace(w_function, '@', '%40');
        end if;
        r_msg := r_msg || chr(10) || 'Atualizar '||p_ds_entity||', requisição individual: '||w_function;
        
        w_resposta := call_request_update(w_json, w_function, w_msg);
        r_msg := r_msg || chr(10) || w_msg;
        
        if /*upper(w_resposta) not like '%ERRO%' and */upper(w_resposta) not like '%EXCEPTION%' and upper(w_resposta) not like '%ERROR%' then
            
            if substr(w_resposta, 1, 1) = '[' then
                w_o_json_list := pljson_list(w_resposta);
                w_o_json := pljson(w_o_json_list.get(1).to_char);
            else 
                w_o_json := pljson(w_resposta);
            end if;
            
            service_updt_db_oracle(p_nm_table, w_o_json, w_chave, w_update, w_msg);
            r_msg := r_msg || chr(10) || w_msg;
            
        else
            raise e_not_update;
        end if;
        
        
--        if call_request_update(w_json, w_function, w_msg) then
--            r_msg := r_msg || chr(10) || w_msg;
--            
--            service_updt_db_oracle(p_nm_table => p_nm_table, p_key => w_chave, p_update => w_update, r_msg => w_msg);
--            r_msg := r_msg || chr(10) || w_msg;
--            
--            --w_sql := 'update '||p_nm_table||' set dt_updt = sysdate where '||w_chave; --to_date('''||to_char(sysdate, 'rrrr-mm-dd HH24:MI:SS')||''', ''rrrr-mm-dd HH24:MI:SS'')
----            w_sql := 'update '||p_nm_table||' set '||w_update||' where '||w_chave;
----            r_msg := r_msg || chr(10) || w_sql;
----            w_msg := '';
----            if not(util_execute_sql(w_sql, w_msg)) then
----                r_msg := r_msg || chr(10) || w_msg;
----                raise e_table_not_update;
----            else
----                r_msg := r_msg || chr(10) || w_msg;
----                r_msg := r_msg || chr(10) || 'Atualizou '||p_nm_table||' ('||w_chave||')';
----            end if;
--           
--        else
--            raise e_not_update;
--        end if;
        exception
            when e_not_update then
                r_msg := r_msg || chr(10) || w_msg;
                r_msg := r_msg || chr(10) || 'Inicio (Error) (service_update_request):';
                r_msg := r_msg || chr(10) || replace(msg_e_not_update, 'dado', 'w_json:'||w_json||chr(10)||'w_function:'||w_function);
                r_msg := r_msg || chr(10) || 'Fim (Error) (service_update_request)';
            when others then
                r_msg := r_msg || chr(10) || 'Inicio (Error) (service_update_request):';
                r_msg := r_msg || chr(10) || p_json;
                r_msg := r_msg || chr(10) || util.get_erro;
                r_msg := r_msg || chr(10) || 'Fim (Error) (service_update_request)';
    end service_update_request;
    
    
    procedure service_delete_request(p_json in clob, p_method in varchar2, p_nm_table in varchar2, p_entity in varchar2, p_ds_entity in varchar2, p_template in varchar2, r_msg out clob) is
        
        l_sql             varchar2(200);
        l_funcao          varchar2(300);
        l_chave           varchar2(200);
        l_update          varchar2(200);
        l_o_json          pljson;
        l_resposta        clob;
        l_msg             clob;
        l_nm_entity       varchar2(100);
    begin
        l_o_json := pljson(util_all_atribute_to_lower(p_json));
        if p_entity is not null then
            util_extract_from_template(l_funcao, l_chave, l_update, lower(p_method), p_template, pljson(l_o_json.get(p_entity)), null);
        else
            util_extract_from_template(l_funcao, l_chave, l_update, lower(p_method), p_template, l_o_json, l_nm_entity);
        end if;
        l_o_json := util_remove_property(l_o_json, pljson(p_template));

        r_msg := r_msg || chr(10) || '"Deletar/Desativar/Concluir" '||p_ds_entity;
        l_resposta := call_request_delete(l_funcao, l_msg);
        r_msg := r_msg || chr(10) || l_msg;
        
        if lower(l_msg) not like '%erro%' and lower(l_msg) not like '%exception%' then
            if l_update like '%<%' then
                r_msg := r_msg || chr(10) || 'before l_update:'||l_update;
                r_msg := r_msg || chr(10) || 'l_resposta:'||l_resposta;
                l_update := util_replace_tag(l_update, l_resposta);
                r_msg := r_msg || chr(10) || 'after l_update:'||l_update;
            end if;
    --            if call_request_delete(l_funcao, l_msg) then
            --l_sql := 'update '||p_nm_table||' set dt_updt = sysdate where '||l_chave; --to_date('''||to_char(sysdate, 'rrrr-mm-dd HH24:MI:SS')||''', ''rrrr-mm-dd HH24:MI:SS'')
            service_updt_db_oracle(p_nm_table => p_nm_table, p_key => l_chave, p_update => l_update, r_msg => l_msg);
            r_msg := r_msg || chr(10) || l_msg;
        else
            raise e_not_deleted;
        end if;
        exception
            when e_no_tag_found then
                r_msg := r_msg || chr(10) || replace(msg_e_no_tag_found, 'dado', '');
            when e_not_deleted then
                r_msg := r_msg || chr(10) || replace(msg_e_not_deleted, 'dado', '');
            when others then
                r_msg := r_msg || chr(10) || 'Inicio Erro:';
                r_msg := r_msg || chr(10) || util.get_erro;
                r_msg := r_msg || chr(10) || 'Fim Erro';
    end service_delete_request;
    
    --Deprecated *remover
    function service_get_method(p_json varchar2, p_method varchar2, p_entity varchar2, p_nm_primary_key varchar2) return varchar2 is
        l_o_json         pljson;
        l_tmp_o_json     pljson;
        r_method         varchar2(100);
        w_nm_primary_key varchar2(100);
    begin
        if instr(p_method, 'dado') > 0 then
            l_tmp_o_json := pljson(p_json);
            if (l_tmp_o_json.exist(p_entity)) then
                l_o_json := pljson(l_tmp_o_json.get(p_entity));
                if lower(p_entity) = 'course_section' then
                    l_o_json := pljson(l_tmp_o_json.get(p_entity));
                    if l_o_json.exist('sis_course_id') then
--                            r_msg := r_msg || chr(10) || 'type???:'||l_o_json.get('sis_course_id').get_string;
                        if l_o_json.get('sis_course_id').typeval = 3 then
                            r_method := replace(p_method, 'dado', l_o_json.get('sis_course_id').get_string);
--                                r_msg := r_msg || chr(10) || 'r_method:'||r_method;
                        elsif l_o_json.get('sis_course_id').typeval = 4 then
                            r_method := replace(p_method, 'dado', to_char(l_o_json.get('sis_course_id').get_number));
                        end if;
                    end if;
                else
                    w_nm_primary_key := lower(p_nm_primary_key);
--                        r_msg := r_msg || chr(10) || 'w_nm_primary_key:'||w_nm_primary_key;
                    if l_o_json.exist(w_nm_primary_key) then
                        if l_o_json.get(w_nm_primary_key).typeval = 3 then
                            r_method := replace(p_method, 'dado', l_o_json.get(w_nm_primary_key).str);
--                                r_msg := r_msg || chr(10) || 'r_method1:'||r_method;
                        elsif l_o_json.get(w_nm_primary_key).typeval = 4 then
                            r_method := replace(p_method, 'dado', to_char(l_o_json.get(w_nm_primary_key).num));
--                                r_msg := r_msg || chr(10) || 'r_method2:'||r_method;
                        end if;
                    end if;
                end if;
            end if;
        else
            return p_method;
        end if;
        return r_method;
    end service_get_method;
    
/**
    Objetivo: Verifica, se desejar, se o id (pela entidade) ja existe no 
    canvas, se sim, atualiza a tabela informada no parâmetro.
    
    @param  p_json              json a ser enviado.
    @param  p_method_find       função de chamada da requisição.
    @param  p_nm_primary_key    nome da chave primaria.
    @param  p_entity            entidade a ser trabalhada.
    @param  p_nm_table          nome da tabela a ser atualizado após o envio da requisição.
    @param  p_verify_id         verificar se o canvas_id já existe caso seja true
    @param  r_msg               <b>retorna</b> o log.
    
    @return boolean true caso id exista.
*/
    function service_is_exist_id(p_json clob, p_method_find varchar2, p_nm_primary_key varchar2, p_entity varchar2, p_nm_table varchar2, p_verify_id boolean, r_msg out clob) return boolean is
        w_o_json         pljson;
        w_tmp_o_json     pljson;
        w_valores        r_r_valores;
        w_vl_primary_key varchar2(100);
        w_canvas_id      varchar2(100);
        w_sql            varchar2(200);
        
        w_function       varchar2(100);
--        w_chave          varchar2(100);
        w_json           varchar2(3000);
        w_nm_primary_key varchar2(100);
        w_msg clob;
    begin
        
        if p_verify_id then
            r_msg := r_msg || chr(10) || 'Iniciar o serviço (service_is_exist_id)';
            w_tmp_o_json := pljson(util_all_atribute_to_lower(p_json));
            
            if w_tmp_o_json.exist(lower(p_entity)) then
                w_o_json := pljson(w_tmp_o_json.get(lower(p_entity)));
            else
                w_o_json := w_tmp_o_json;
            end if;
                
            w_nm_primary_key := substr(p_method_find, instr(p_method_find, '<') + 1, (instr(p_method_find, '>') - 1) - instr(p_method_find, '<'));
            
            
            if w_o_json.get(lower(w_nm_primary_key)).typeval = 3 then
                w_vl_primary_key := w_o_json.get(lower(w_nm_primary_key)).STR;
            elsif w_o_json.get(lower(w_nm_primary_key)).typeval = 4 then
                w_vl_primary_key := to_char(w_o_json.get(lower(w_nm_primary_key)).num);
            end if;
            
            w_function := replace(p_method_find, '<'||w_nm_primary_key||'>', w_vl_primary_key);
            
            r_msg := r_msg || chr(10) || 'Buscar '||p_entity||', requisição individual: '||w_function;
            w_valores := get_valores(dao_find_all(replace(w_function, '@','%40'), r_msg => w_msg));
            r_msg := r_msg || chr(10) || w_msg;
            for i in 1..w_valores.count loop
                declare
                    j binary_integer;
                begin
                    j := 1;
                    while w_canvas_id is null or j > w_valores(i).last loop 
                        if upper(w_valores(i)(j).atributo) = 'ID' then
                            w_canvas_id := UTIL.REMOVE_LINES(UTIL.REMOVE_ALL_SPECIAL_CHARACTER(w_valores(i)(j).valor, keep_words));
                        end if;
                        j := j + 1;
                    end loop;
                    exception
                        when others then
                            r_msg := r_msg || chr(10) || 'Inicio Erro:';
                            r_msg := r_msg || chr(10) || util.get_erro;
                            r_msg := r_msg || chr(10) || 'Fim Erro';
                end;
                for j in 1..w_valores(i).last loop
                    if upper(w_nm_primary_key) = upper(UTIL.REMOVE_LINES(UTIL.REMOVE_ALL_SPECIAL_CHARACTER(w_valores(i)(j).atributo, keep_words))) then
                        if w_vl_primary_key = UTIL.REMOVE_LINES(UTIL.REMOVE_ALL_SPECIAL_CHARACTER(w_valores(i)(j).valor, keep_words)) then
                            r_msg := r_msg || chr(10) || 'já existe ('||w_vl_primary_key||') canvas_id ('||w_canvas_id||')';
                            w_sql := 'update '||p_nm_table||' set dt_incl = to_date('''||to_char(sysdate, 'rrrr-mm-dd HH24:MI:SS')||''', ''rrrr-mm-dd HH24:MI:SS''), canvas_id = '||w_canvas_id||' where '||w_nm_primary_key||' = '''||UTIL.REMOVE_LINES(UTIL.REMOVE_ALL_SPECIAL_CHARACTER(w_valores(i)(j).valor, keep_words))||'''';
                            r_msg := r_msg || chr(10) || w_sql;
                            w_msg := '';
                            if util_execute_sql(w_sql, w_msg) then
                                r_msg := r_msg || chr(10) || w_msg;
                                return true;
                            else
                                r_msg := r_msg || chr(10) || w_msg;
                                raise e_table_not_update;
                            end if;
                            exit;
                        end if;
                    end if;
                end loop;
            end loop;
            return false;
        end if;
        return false;
        exception
            when others then
                r_msg := r_msg || chr(10) || 'Inicio Erro:';
                if w_msg is not null then r_msg := r_msg || w_msg; end if;
                r_msg := r_msg || chr(10) || util.get_erro;
                r_msg := r_msg || chr(10) || 'Fim Erro';
                return false;
    end service_is_exist_id;
    
/**
    Serviço para buscar conforme parâmetro que retorna a resposta em string.
    
    @param  p_nm_method     nome da função da chmada para buscar os dados.
    @param  exibir_json     exibiar json retornado.
    @return string json retornada.
*/
    function service_find_by(p_nm_method in varchar2, r_msg out clob, exibir_json in boolean default false) return clob is
        geral  pljson;
        lista  pljson_list;
        tmp    pljson;
        w_json clob;
        w_msg  clob;
    begin
--        util.p('iniciar service_find_by');
        r_msg := r_msg || chr(10) || 'Realizar chamada do metodo: '||p_nm_method;
        w_json := dao_find_all(replace(p_nm_method,'@','%40'), r_msg => w_msg);
        r_msg := r_msg || chr(10) || w_msg;
--        util.p('resposta:'||w_json);
--util.plob(coalesce(w_msg, 'vazio'));
--        if g_is_debug then util.plob(w_msg); end if;
        if exibir_json then 
            geral := pljson('{"show": '||w_json||'}');
            geral.print;
            lista := pljson_list(geral.get('show'));
--            util.p('Quantidade:'||lista.count);
--            for i in 1..lista.count loop                
----                    tmp := service_remove_empty_column(json(lista.get(i)));
--                util.p('('||i||')----------------------------------------------------------------------------------');
--                lista.get(i).print;
----                    tmp.print(false);
--                util.p('('||i||')----------------------------------------------------------------------------------');
--            end loop;
        end if;
        return w_json;
    end;

    procedure service_update_table_user(p_usuario canvas_usuarios%rowtype, r_msg out clob) is
        w_usuario canvas_usuarios%rowtype;
    begin
        if dao_update_table_user(p_usuario) then
            r_msg := 'Usuário atualizado com sucesso!';
        else
            r_msg := 'Usuário não atualizado!';
        end if;
    end;
    
/**
    <p>
    Serviço para realizar a chamada da atualização da nota.
    </p>
    @param  p_js_nota   json contendo os dados da nota.
    @param  r_msg       retorna o log.
*/    
    procedure service_update_table_notas(p_js_nota in pljson, r_msg out clob) is
        w_nota canvas_notas%rowtype;
    begin
        r_msg := 'Atualizar nota:';
        
        w_nota := get_nota(p_js_nota);
         
        r_msg := r_msg || chr(10) || p_js_nota.to_char;  
        if dao_update_table_nota(w_nota) then
            r_msg := r_msg || chr(10) || 'Nota atualizado com sucesso!';
        else
            r_msg := r_msg || chr(10) || 'Nota não atualizada!';
        end if;
        exception
            when others then
                r_msg := r_msg || chr(10) || UTIL.GET_ERRO;
    end;
    
/**
    <p>
    Serviço para realizar a chamada da inserção da nota.
    </p>
    @param  p_js_nota   json contendo os dados da nota.
    @param  r_msg       retorna o log.
*/    
    procedure service_insert_table_notas(p_js_nota in pljson, r_msg out clob) is
        w_nota canvas_notas%rowtype;
    begin
        r_msg := 'Inserir nota:';
        
        w_nota := get_nota(p_js_nota);
        r_msg := r_msg || chr(10) || p_js_nota.to_char;  
        r_msg := r_msg || chr(10) || 'final_score:'||w_nota.final_score;
        r_msg := r_msg || chr(10) || 'current_score:'||w_nota.current_score;
        
        if w_nota.final_score is not null or w_nota.final_score >= 0 
        or w_nota.current_score is not null or w_nota.current_score >= 0 then
            if dao_insert_table_nota(w_nota) then
                r_msg := r_msg || chr(10) || 'Nota inserido com sucesso!';
            else
                r_msg := r_msg || chr(10) || 'Nota não inserida!';
            end if;
        else
            r_msg := r_msg || chr(10) || 'Sem score, nota não será inserido';
        end if;
        exception
            when others then
                r_msg := r_msg || chr(10) || UTIL.GET_ERRO;
    end;
    
/**
    Objetivo: atualizar a tabela canvas conforme os parâmetros, se basendo no template informado, usamos a função
    <em>util_extract_from_template</em> para extrair a variável chave e update, onde a chave irá compor o <em>update</em> 
    <b>"where"</b> e <em>update</em>, são os campos a serem <b>"set"</b>(setados), em seguida remove os campos do json, 
    conforme o <em>template</em>, caso ainda exista <em>tags</em> (<?>), então irá substituir por algum dado do json, feito isso
    iremos chamar o serviço que realiza a atualiação da tabela com os parâmetros:
    <ul>
        <li>p_nm_table => nome da tabela</li>
        <li>l_chave => chave onde foi extraido do template</li>
        <li>l_update => campos que serão atualizados</li>
        <li>l_msg => mensagem de retorno.</li>
    </ul>
    
    @param  p_json      json a ser baseado para atualização da tabela
    @param  p_method    metodo de busca da rquisição desejada
    @param  p_nm_table  nome da tabela
    @param  p_entity    nome da entidade
    @param  p_template  json template
    @param  r_msg       mensagem de retorno (log)
    
*/
    procedure service_update_table_canvas(p_json clob, p_method varchar2, p_nm_table varchar2, p_entity varchar2, p_template varchar2, r_msg out clob) is
        l_funcao          varchar2(300);
        l_chave           varchar2(200);
        l_update          varchar2(200);
        l_o_json          pljson;
        l_resposta        clob;
        l_msg             clob;
        l_nm_entity       varchar2(200);
    begin
        l_o_json := pljson(util_all_atribute_to_lower(p_json));
        if p_entity is not null then
            util_extract_from_template(l_funcao, l_chave, l_update, lower(p_method), p_template, pljson(l_o_json.get(p_entity)), null);
        else
            util_extract_from_template(l_funcao, l_chave, l_update, lower(p_method), p_template, l_o_json, l_nm_entity);
        end if;
        l_o_json := util_remove_property(l_o_json, pljson(p_template));
    
        --r_msg := r_msg || chr(10) || '"Deletar/Desativar/Concluir" '||p_ds_entity;
        --l_resposta := call_request_delete(l_funcao, l_msg);
        --r_msg := r_msg || chr(10) || l_msg;
        
        --if lower(l_msg) not like '%erro%' and lower(l_msg) not like '%exception%' then
            if l_update like '%<%' then
                r_msg := r_msg || chr(10) || 'before l_update:'||l_update;
                r_msg := r_msg || chr(10) || 'l_resposta:'||p_json;
                l_update := util_replace_tag(l_update, p_json);
                r_msg := r_msg || chr(10) || 'after l_update:'||l_update;
            else                
                r_msg := r_msg || chr(10) || 'l_update:'||l_update;
            end if;
            r_msg := r_msg || chr(10) || 'p_nm_table:'||p_nm_table;
            r_msg := r_msg || chr(10) || 'l_chave:'||l_chave;
    
            service_updt_db_oracle(p_nm_table => p_nm_table, p_key => l_chave, p_update => l_update, r_msg => l_msg);
            r_msg := r_msg || chr(10) || l_msg;
        --else
        --    raise e_not_deleted;
        -- end if;
        exception
            when e_no_tag_found then
                r_msg := r_msg || chr(10) || replace(msg_e_no_tag_found, 'dado', '');
            when e_not_deleted then
                r_msg := r_msg || chr(10) || replace(msg_e_not_deleted, 'dado', '');
            when others then
                r_msg := r_msg || chr(10) || 'Inicio Erro:';
                r_msg := r_msg || chr(10) || util.get_erro;
                r_msg := r_msg || chr(10) || 'Fim Erro';
    end;
    
    /****************************Termino Serviços******************************/
    
    
    /***************************Inicio Controller******************************/
/**
    Objetivo: tratar o formato do json para enviar na requisição.
    
    @param  p_pljson        json a ser configurado.
    @param  p_entity        nome da entidade.
    @param  p_template      template como referência. 
    @param  validate_json   validar json caso true.
    
    @return string do json tratado.
    @throws e_formato_json_invalido msg_formato_json_invalido.
*/
    function controller_prepare_json(p_pljson pljson, p_entity in varchar2, p_template varchar2, validate_json boolean, r_msg out clob) return varchar2 is
        tmp_json pljson;
        w_str_json clob;
    begin
        if p_entity is not null then
            r_msg := r_msg || chr(10) || 'Remover atributos vazios';
            tmp_json := util_remove_empty_column(p_pljson);
            w_str_json := '{"'||upper(p_entity)||'":'||tmp_json.to_char(false)||'}';
        else
            r_msg := r_msg || chr(10) || 'Remover atributos vazios';
            tmp_json := util_remove_empty_column(p_pljson);
            w_str_json := tmp_json.to_char(false);
        end if;
        if validate_json then
            r_msg := r_msg || chr(10) || 'Validar a estrutura do json com base no template';
            if not(util_validate_json(p_template, upper(w_str_json))) then
                raise e_formato_json_invalido;
            end if;
        end if;
        return w_str_json;
        exception
            when e_formato_json_invalido then
                r_msg := r_msg || chr(10) || 'Inicio Erro;';
                r_msg := r_msg || chr(10) || replace(msg_e_formato_json_invalido, 'dado', coalesce(w_str_json, ''));
                r_msg := r_msg || chr(10) || 'Fim Erro';
            when others then
                r_msg := r_msg || chr(10) || 'Inicio Erro;';
                r_msg := r_msg || chr(10) || util.get_erro;
                r_msg := r_msg || chr(10) || 'Fim Erro';
    end;
    
    
    procedure ctl_extract_info(r_o_json   out pljson,
                               r_str_json out clob,
                               r_function out varchar2, 
                               r_key      out varchar2,
                               r_update   out varchar2,
                               p_method    in varchar2, 
                               p_entity    in varchar2,
                               p_template  in varchar2) is
        r_pljson pljson;
    begin
        r_o_json := pljson(util_all_atribute_to_lower(r_str_json));
        
        util_extract_from_template(r_function, r_key, r_update, lower(p_method), p_template, pljson(r_o_json.get(p_entity)), p_entity);
        
        r_o_json   := util_remove_property(r_o_json, pljson(p_template));
        r_str_json := r_o_json.to_char(false);
        r_function := util_convert_ascii_to_hex(r_function);
        --r_msg      := r_msg || chr(10) || 'Função de chamada: '||r_function;--REMOVER
        
    end;
    
    procedure ctl_get_key_when_batch(r_key out varchar2) is
        qt_perco integer;
    begin
        qt_perco := length(r_key) - length(replace(r_key,'=',null));
        for i in 1..qt_perco loop
            if i = 1 then
                r_key := substr(r_key, 1, instr(r_key, '='))||'<'||substr(r_key, 1, instr(r_key, '=') - 1)||'>';
            else
                r_key := substr(r_key, instr(r_key, 'and', 1, i -1) + 3, (instr(r_key, '=', 1, i) + 1) - (instr(r_key, 'and', 1, i - 1) + 3)) || '<'||substr(r_key, instr(r_key, 'and', 1, i - 1) + 3, instr(r_key, '=', 1, i) - (instr(r_key, 'and', 1, i - 1) + 3))||'>';
            end if; 
        end loop;
    end;
    
    
    procedure ctl_log_footer(r_msg           out clob,
                             p_qt_atualizado  in number,
                             p_qt_inserido    in number,
                             p_ds_entity      in varchar2) is
    begin
        if p_qt_atualizado > 0 then
            r_msg := r_msg || chr(10) || 'Atualizado: '||to_char(p_qt_atualizado);
        end if;
        r_msg := r_msg || chr(10) || 'Inserido: '||to_char(p_qt_inserido);
        r_msg := r_msg || chr(10) || 'Fim do metodo insert: '||p_ds_entity||'(s)';
    end;
    
    
--    procedure controller_extract_info(p_json clob, r_json out clob, r_function out varchar2, r_key out varchar2, r_update out varchar2, p_method varchar2, p_entity varchar2, p_template varchar2) is
--    
--        w_function varchar2(200);
--        w_key      varchar2(200);
--        w_update   varchar2(200);
--        w_json     clob;
--        w_o_json   json;
--    begin
--        w_o_json   := json(util_all_atribute_to_lower(p_json));
--        util_extract_from_template(w_function, w_key, w_update, lower(p_method), p_template, json(w_o_json.get(p_entity)), p_entity);
--        
--        w_o_json   := util_remove_property(w_o_json, json(p_template));
--        r_json     := w_o_json.to_char(false);
--        
--        r_function := util_convert_ascii_to_hex(w_function);
--        r_key      := w_key;
--        r_update   := w_update;
----        r_msg := r_msg || chr(10) || 'Função de chamada: '||w_function;
--    end;
--    
--    function get_key_when_batch(p_key varchar2) return varchar2 is
--        qt_perco integer;
--        w_key varchar2(500);
--    begin
--        w_key := p_key;
--        qt_perco := length(w_key) - length(replace(w_key,'=',null));
--        for i in 1..qt_perco loop
--            if i = 1 then
--                w_key := substr(w_key, 1, instr(w_key, '='))||'<'||substr(w_key, 1, instr(w_key, '=') - 1)||'>';
--            else
--                w_key := substr(w_key, instr(w_key, 'and', 1, i -1) + 3, (instr(w_key, '=', 1, i) + 1) - (instr(w_key, 'and', 1, i - 1) + 3)) || '<'||substr(w_key, instr(w_key, 'and', 1, i - 1) + 3, instr(w_key, '=', 1, i) - (instr(w_key, 'and', 1, i - 1) + 3))||'>';
--            end if; 
--        end loop;
--        return w_key;
--    end;
--    
--    procedure controller_list_save(p_json clob, p_entity varchar2, p_method varchar2, p_nm_table varchar2, p_template varchar2, p_verify_id boolean, is_batch boolean, p_method_find varchar2, r_function out varchar2, r_msg out clob) is
--        w_msg clob;
--        w_function varchar2(200);
--        w_key varchar2(200);
--        w_update varchar2(200);
--        w_new_json clob;
--    begin
--        if is_batch then
--            if  w_json_list.count = i then
--                w_lista_json := w_lista_json ||','||p_json||']';
--            elsif w_lista_json is not null then
--                w_lista_json := w_lista_json|| ','||p_json;
--            else
--                extract_info;
--                controller_extract_info(p_json, w_new_json, w_function, w_key, w_update, p_method, p_entity, p_template);
--                w_key := get_key_when_batch(w_key);
--                w_lista_json := '['||p_json;
--            end if;
--        else
--            controller_extract_info(p_json, w_new_json, w_function, w_key, w_update, p_method, p_entity, p_template);
--            service_save_request(w_new_json, w_function, w_key, w_update, p_nm_table, is_batch, w_msg);
--            r_msg := r_msg || chr(10) || w_msg;
--            if r_msg not like '%erro%' then
--                w_qt_inserido := (w_qt_inserido + 1);
--            end if;
--        end if;
--    end controller_list_save;
    
/**
    Padronizar a forma de salvar/criar/enviar uma chamada de
    requisição.
    <b>Procedimento:</b>
    <p>log_footer: log de rodapé</p>
    
    @param  p_sql           select a ser enviado.
    @param  p_method        metodo a ser utilizado na  chamada.
    @param  p_ds_entity     descrição da entidade a ser chamada (Usuário, Curso,...).
    @param  p_entity        nome da entidade (user, course, term, etc).
    @param  p_nm_table      nome da tabela que será atualizada no base oracle.
    @param  p_template      template padrão referente da entidade.
    @param  is_batch        em lote.
    @param  p_verify_id     verifica se o id ja existe no canvas.     
    @param  p_method_find   metodo de busca para buscar o id no canvas.
    @param  r_msg           <b>retorna</b> o log.
    
*/
    procedure controller_save_request(p_sql in varchar2, p_method in varchar2, p_ds_entity in varchar2, p_entity in varchar2, p_nm_table in varchar2, p_template in varchar2, is_batch in boolean, p_verify_id in boolean,r_msg out clob, p_method_find varchar2 default '?&search_term=', is_update boolean default true) is
    
        w_nm_primary_key varchar2(100);
        w_id             varchar2(100);
        w_qt_inserido    integer;
        w_qt_atualizado  integer := 0;
        w_str_json       clob;
        w_msg            clob;  
        w_json_list      pljson_list;    
        w_o_json         pljson;
        w_lista_json     clob;
        
        procedure log_footer is
        begin
            if w_qt_atualizado > 0 then
                r_msg := r_msg || chr(10) || 'Atualizado: '||to_char(w_qt_atualizado);
            end if;
            r_msg := r_msg || chr(10) || 'Inserido: '||to_char(w_qt_inserido);
            r_msg := r_msg || chr(10) || 'Fim do metodo insert: '||p_ds_entity||'(s)';
        end;
        
    begin
        
        w_qt_inserido := 0;
        if instr(upper(p_entity), 'COURSE_SECTION') > 0 or instr(upper(p_entity), 'ENROLLMENT') > 0 then 
            w_nm_primary_key := 'SIS_SECTION_ID';
        else
            w_nm_primary_key := 'SIS_'||upper(p_entity)||'_ID';
        end if;
        if is_debug then util.p(p_sql); end if;
        r_msg := 'Inicio do método insert: '||p_method;
        r_msg := r_msg || chr(10) || 'Inserir:' || p_ds_entity;
        if upper(p_sql) like '%"'||upper(p_entity)||'"%' or upper(p_entity) = 'GROUP' then
            if is_batch then
                r_msg := r_msg || chr(10) || 'Converter StringJson em PLJSON';
                w_json_list := pljson_list(p_sql);
                r_msg := r_msg || chr(10) || 'Iniciar requisição em lote';
                w_str_json := controller_prepare_json(pljson(w_json_list.get(1)), p_entity, p_template, true, w_msg);
                r_msg := r_msg || chr(10) || w_msg;
                r_msg := r_msg || chr(10) || 'Chamada do serviço (service_save_request)';
                service_save_request(w_str_json, p_entity, p_nm_table, p_method, p_template, is_batch, w_msg, is_update);
                
            else
                r_msg := r_msg || chr(10) || p_sql;
                r_msg := r_msg || chr(10) || 'Requisição individual';
                w_str_json := controller_prepare_json(pljson(p_sql), null, p_template, true, w_msg);
                r_msg := r_msg || chr(10) || w_msg;
                r_msg := r_msg || chr(10) || 'Chamada do serviço (service_save_request)';
                service_save_request(w_str_json, null, p_nm_table, p_method, p_template, is_batch, w_msg, is_update);
                r_msg := r_msg || chr(10) || w_msg;
            end if;
        else
            
            r_msg := r_msg || chr(10) || 'Converter sql em lista de json';
            w_json_list := JSON_UTIL_PKG.SQL_TO_JSON(p_sql);
            r_msg := r_msg || chr(10) || 'Quantidade a ser inserido: '||w_json_list.count;
            r_msg := r_msg || chr(10) || 'Iniciar requisição em lote';
--            if is_batch then
--                raise e_batch_not_found;
--            end if;
            for i in 1..w_json_list.count loop
--                declare
--                    tmp_json pljson;
                begin
--                    tmp_json := util_remove_empty_column(json(w_json_list.get(i)));
--                    w_str_json := '{"'||upper(p_entity)||'":'||tmp_json.to_char(false)||'}';
--                    w_str_json := replace(w_str_json, 'null', '""');
                    r_msg := r_msg || chr(10) || '-----------------------------------------------------------------------------';
                    w_str_json := controller_prepare_json(pljson(w_json_list.get(i)), p_entity, p_template, true, w_msg);
                    r_msg := r_msg || chr(10) || w_msg;
                    if not(service_is_exist_id(w_str_json, p_method_find, w_nm_primary_key, p_entity, p_nm_table, p_verify_id, w_msg)) then
                        r_msg := r_msg || chr(10) || w_msg;
--                        if not(util_validate_json(p_template, w_str_json)) and i = 1 then
--                            r_msg := r_msg || chr(10) || w_str_json;
--                            raise e_formato_json_invalido;
--                        else
                            if is_batch then
                                if  w_json_list.count = i then
                                    w_lista_json := w_lista_json ||','||w_str_json||']';
                                elsif w_lista_json is not null then
                                    w_lista_json := w_lista_json|| ','||w_str_json;
                                else
--                                    extract_info;
--                                    get_key_when_batch;
                                    w_lista_json := '['||w_str_json;
                                end if;
                            else
                                service_save_request(w_str_json, p_entity, p_nm_table, p_method, p_template, is_batch, w_msg, is_update);
--                                extract_info;
--                                service_save_request(w_str_json, w_function, w_key, w_update, p_nm_table, is_batch, w_msg);
                                r_msg := r_msg || chr(10) || w_msg;
                                if r_msg not like '%erro%' then
                                    w_qt_inserido := (w_qt_inserido + 1);
                                end if;
                            end if;
--                        end if;
                        
                    else
                        r_msg := r_msg || chr(10) || w_msg;
                        w_qt_atualizado := w_qt_atualizado + 1;
                    end if;
                    
                exception
                    when e_table_not_update then
                        r_msg := r_msg || chr(10) || w_msg;
                        r_msg := r_msg || chr(10) || replace(msg_e_table_not_update, 'dado', 'Não atualizou ('||p_nm_table||')');
                    when e_formato_json_invalido then
                        r_msg := r_msg || chr(10) || w_msg;
                        r_msg := r_msg || chr(10) || replace(msg_e_formato_json_invalido, 'dado', 'Template:'||p_template||chr(10)||w_str_json);
                    when others then
                        r_msg := r_msg || chr(10) || w_msg;
                        r_msg := r_msg || chr(10) || 'Inicio Erro:';
                        r_msg := r_msg || chr(10) || util.get_erro;
                        r_msg := r_msg || chr(10) || 'Fim Erro';
                end;
            end loop;
            if is_batch then
--                util.p('w_lista_json:'||w_lista_json);
--                util.p('w_function:'||w_function);
--                util.p('w_key:'||w_key);
--                util.p('w_update:'||w_update);
--                service_save_request(w_lista_json, w_function, w_key, w_update, p_nm_table, is_batch, w_msg);
                service_save_request(w_lista_json, p_entity, p_nm_table, p_method, p_template, is_batch, w_msg);
                r_msg := r_msg || chr(10) || w_msg;
            end if;
        end if;
            log_footer;
        exception
            when e_formato_json_invalido then
                r_msg := r_msg || chr(10) || w_msg;
                r_msg := r_msg || chr(10) || replace(msg_e_formato_json_invalido, 'dado', '');
                log_footer;
            when e_batch_not_found then
                r_msg := r_msg || chr(10) || w_msg;
                r_msg := r_msg || chr(10) || msg_e_batch_not_found;
                log_footer;
            when others then
                r_msg := r_msg || chr(10) || w_msg;
                r_msg := r_msg || chr(10) || 'Inicio Erro:';
                r_msg := r_msg || chr(10) || util.get_erro;
                r_msg := r_msg || chr(10) || 'Fim Erro';
                log_footer;
    end controller_save_request;
    
/**
    Requisição de insert para inscrições
    
    @param  p_sql           select a ser enviado.
    @param  p_method        metodo a ser utilizado na  chamada.
    @param  p_ds_entity     descrição da entidade a ser chamada (Usuário, Curso,...).
    @param  p_entity        nome da entidade (user, course, term, etc).
    @param  p_nm_table      nome da tabela que será atualizada no base oracle.
    @param  p_template      template padrão referente da entidade.
    @param  is_batch        em lote.
    @param  p_verify_id     verifica se o id ja existe no canvas       .     
    @param  p_method_find   metodo de busca para buscar o id no canvas.
    @param  r_msg           <b>retorna</b> o log.
    
*/
    procedure controller_save_ins(p_sql in varchar2, p_method in varchar2, p_ds_entity in varchar2, p_entity in varchar2, p_nm_table in varchar2, p_template in varchar2, is_batch in boolean, p_verify_id in boolean,r_msg out clob, p_method_find varchar2 default '?&search_term=') is
    
        w_nm_primary_key varchar2(100);
--        w_id             varchar2(100);
        w_qt_inserido    integer;
        w_qt_atualizado  integer := 0;
        w_str_json       clob;
        w_msg            clob;  
        w_json_list      pljson_list;    
        w_o_json         pljson;
        w_lista_json     clob;
        
        procedure log_footer is
        begin
            if w_qt_atualizado > 0 then
                r_msg := r_msg || chr(10) || 'Atualizado: '||to_char(w_qt_atualizado);
            end if;
            r_msg := r_msg || chr(10) || 'Inserido: '||to_char(w_qt_inserido);
            r_msg := r_msg || chr(10) || 'Fim do metodo insert: '||p_ds_entity||'(s)';
        end;
        
    begin
        
        w_qt_inserido    := 0;
        w_nm_primary_key := 'SIS_'||upper(p_entity)||'_ID';
                
        if upper(p_sql) like '%"'||upper(p_entity)||'"%' then
            controller_save_request(p_sql, p_method, p_ds_entity, p_entity, p_nm_table, p_template, is_batch, p_verify_id, w_msg, p_method_find);
            r_msg := r_msg || chr(10) || w_msg;
        else
            
            r_msg := r_msg || chr(10) || 'Converter sql em lista de json';
            w_json_list := JSON_UTIL_PKG.SQL_TO_JSON(p_sql);
            r_msg := r_msg || chr(10) || 'Quantidade a ser inserido: '||w_json_list.count;
            r_msg := r_msg || chr(10) || 'Criar vários '||p_ds_entity||'s, requisição individual: '||p_method;
            
            for i in 1..w_json_list.count loop
                begin
                    w_o_json := pljson(w_json_list.get(i));
                    w_str_json := controller_prepare_json(w_o_json, p_entity, p_template, true, w_msg);
                    r_msg := r_msg || chr(10) || w_msg;
                    if not(service_is_exist_id(w_str_json, p_method_find, w_nm_primary_key, p_entity, p_nm_table, p_verify_id, w_msg)) then
                        r_msg := r_msg || chr(10) || w_msg;
                        controller_save_request(w_str_json, p_method, p_ds_entity, p_entity, p_nm_table, p_template, is_batch, p_verify_id, w_msg, p_method_find);
                        r_msg := r_msg || chr(10) || w_msg;
                        if r_msg not like '%erro%' then
                            w_qt_inserido := (w_qt_inserido + 1);
                        end if;
                        
                        declare
                            v_type        pljson_value;
                            v_group       pljson_value;
                            v_sis_user_id pljson_value;
                            v_json        varchar2(1000);
                        begin
                            v_type := w_o_json.get('TYPE');
                            if v_type.str != 'StudentEnrollment' then
                                v_group := w_o_json.get('GROUP_ID');
                                v_sis_user_id := w_o_json.get('SIS_USER_ID');
                                r_msg := r_msg || chr(10)|| chr(10) || 'Vincular '||coalesce(v_sis_user_id.str, to_char(v_sis_user_id.num))||', tipo '||coalesce(v_type.str,to_char(v_type.num))||' ao grupo '||coalesce(v_group.str,to_char(v_group.num));
                                v_json := 
                                '{'||
                                    '"group_id":"'||coalesce(v_group.str,to_char(v_group.num))||'",'||
                                    '"sis_user_id":"'||coalesce(v_sis_user_id.str, to_char(v_sis_user_id.num))||'",'||
                                    '"user_id":"sis_user_id:'||coalesce(v_sis_user_id.str, to_char(v_sis_user_id.num))||'"'||
                                '}';
--                                r_msg := r_msg || chr(10) || v_json;
                                controller_save_request(v_json, 'groups/group_id:<group_id>/memberships', 'vincular_grupo', 'group', '', json_template_link_group, false, false, w_msg, '', false);
                                r_msg := r_msg || chr(10) || w_msg;
                            end if;
                        end;
                    else
                        r_msg := r_msg || chr(10) || w_msg;
                        if r_msg not like '%erro%' then
                            w_qt_atualizado := w_qt_atualizado + 1;
                        end if;
                    end if;
                    
                    r_msg := r_msg || chr(10) || '------------------FIM-------------------------';
                exception
                    when e_formato_json_invalido then
                        r_msg := r_msg || chr(10) || w_msg;
                        r_msg := r_msg || chr(10) || replace(msg_e_formato_json_invalido, 'dado', 'Template:'||p_template||chr(10)||w_str_json);
                        r_msg := r_msg || chr(10) || '------------------FIM-------------------------';
                    when others then
                        r_msg := r_msg || chr(10) || w_msg;
                        r_msg := r_msg || chr(10) || 'Inicio Erro:';
                        r_msg := r_msg || chr(10) || util.get_erro;
                        r_msg := r_msg || chr(10) || 'Fim Erro';
                        r_msg := r_msg || chr(10) || '------------------FIM-------------------------';
                end;
            end loop;
            if is_batch then
--                service_save_request(w_lista_json, p_entity, p_nm_table, p_method, p_template, is_batch, w_msg);
                r_msg := r_msg || chr(10) || w_msg;
            end if;
        end if;
        log_footer;
        exception
            when others then
                r_msg := r_msg || chr(10) || w_msg;
                r_msg := r_msg || chr(10) || 'Inicio Erro:';
                r_msg := r_msg || chr(10) || util.get_erro;
                r_msg := r_msg || chr(10) || 'Fim Erro';
                log_footer;
    end controller_save_ins;
    
/**
    Padronizar a forma de atualizar uma chamada de requisição.
    
    @param  p_sql       select a ser enviado.
    @param  p_method    metodo a ser utilizado na  chamada.
    @param  p_ds_entity descrição da entidade a ser chamada (Usuário, Curso,..).
    @param  p_entity    nome da entidade (user, course, term, etc).
    @param  p_nm_table  nome da tabela que será atualizada no base oracle.
    @param  p_template  template padrão referente da entidade.
    @param  r_msg       <b>retorna</b> o log.

    */
    procedure controller_update_request(p_sql in varchar2, p_method in varchar2, p_ds_entity in varchar2, p_entity in varchar2, p_nm_table in varchar2, p_template in varchar2, r_msg out clob) is --p_nm_updt_id varchar2 ,
        
        w_nm_primary_key varchar2(100);
        w_qt             number;
        w_json           clob;
        w_msg            clob;
        w_json_list      pljson_list;
        w_o_json         pljson;
        w_tmp_o_json     pljson;
        
        procedure log_footer is
        begin
            if w_qt > 0 then
                r_msg := r_msg || chr(10) || 'Atualizado: '||TO_CHAR(w_qt);
            end if;
            r_msg := r_msg || chr(10) || 'Fim do metodo update: '||p_ds_entity||'(s)';
        end;
    begin
        w_qt := 0;
--        if p_entity is null then
--            r_msg := r_msg || chr(10) || 'Erro: deve informar o parâmetro p_entity';
--        else
    --        w_nm_primary_key := 'SIS_'||upper(p_entity)||'_ID';
        r_msg := 'Inicio do método update: '||p_method;
        r_msg := r_msg || chr(10) || 'Atualizar:' || p_ds_entity;
        if upper(p_sql) like '%"'||upper(p_entity)||'"%' then
        
            r_msg := r_msg || chr(10) || 'Iniciar requisição individual';
            w_json := controller_prepare_json(pljson(p_sql), p_entity, p_template, true, w_msg);
            r_msg := r_msg || chr(10) || w_msg;
            r_msg := r_msg || chr(10) || 'Chamada do serviço (service_update_request)';
            service_update_request(w_json, p_method, p_nm_table, null, p_ds_entity, p_template, w_msg);
            r_msg := r_msg || chr(10) || w_msg;

        else
            r_msg := r_msg || chr(10) || 'Converter sql em lista de json';
            w_json_list := JSON_UTIL_PKG.SQL_TO_JSON(p_sql);
            r_msg := r_msg || chr(10) || 'Iniciar requisição de ATUALIZAÇÃO de '||p_ds_entity||'(s)';
            r_msg := r_msg || chr(10) || 'Quantidade a ser atualizado: '||w_json_list.count||'';
            
            for i in 1..w_json_list.count loop
                declare
                    tmp_json pljson;
                begin
                    r_msg := r_msg || chr(10) || '-----------------------------------------------------------------------------';
                    w_json := controller_prepare_json(pljson(w_json_list.get(i)), p_entity, p_template, true, w_msg);
                    r_msg := r_msg || chr(10) || w_msg;
                    
                    r_msg := r_msg || chr(10) || 'Enviar:'||w_json;
                    r_msg := r_msg || chr(10) || 'Chamado do serviço (service_update_request)';
                    service_update_request(w_json, p_method, p_nm_table, p_entity, p_ds_entity, p_template, w_msg);
                    r_msg := r_msg || chr(10) || w_msg;
                    w_qt := (w_qt + 1);
                    
                exception
--                        when e_not_update then
--                            r_msg := r_msg || chr(10) || w_msg;
--                            r_msg := r_msg || chr(10) || replace(msg_e_not_update, 'dado', 'Metodo2:'||p_method);
--                        when e_table_not_update then
--                            r_msg := r_msg || chr(10) || w_msg;
--                            r_msg := r_msg || chr(10) || replace(msg_e_table_not_update, 'dado', 'Tabela ' || p_nm_table ||' não atualizada ');
--                        when e_formato_json_invalido then
--                            r_msg := r_msg || chr(10) || w_msg;
--                            r_msg := r_msg || chr(10) || replace(msg_e_formato_json_invalido, 'dado', coalesce(w_json, ''));
                    when others then
                        r_msg := r_msg || chr(10) || w_msg;
                        r_msg := r_msg || chr(10) || 'Inicio Erro (controller_update_request)';
                        r_msg := r_msg || chr(10) || 'SQL/JSON: '||chr(10)||coalesce(w_json, p_sql);
                        r_msg := r_msg || chr(10) || util.get_erro;
                        r_msg := r_msg || chr(10) || 'Fim Erro (controller_update_request)';
                end;
            end loop;
        end if;
        log_footer;
--        end if;
        exception
--            when e_not_update then
--                r_msg := r_msg || chr(10) || replace(msg_e_not_update, 'dado', 'Metodo:'||p_method);
--            when e_table_not_update then
--                r_msg := r_msg || chr(10) || replace(msg_e_table_not_update, 'dado', 'Tabela ' || p_nm_table ||' não atualizada ');
--            when e_id_not_found then
--                r_msg := r_msg || chr(10) || replace(msg_e_id_not_found, 'dado', w_nm_primary_key||' not found');
--                log_footer;
--            when e_formato_json_invalido then
--                r_msg := r_msg || chr(10) || replace(msg_e_formato_json_invalido, 'dado', 'Template: '||p_template || chr(10) || coalesce(w_json, p_sql));
--                log_footer;
--            when e_id_canvas_not_found then
--                r_msg := r_msg || chr(10) || replace(msg_e_id_canvas_not_found, 'dado', coalesce(w_json, 'CANVAS_ID not found'));
--                log_footer;
            when others then
                r_msg := r_msg || chr(10) || w_msg;
                r_msg := r_msg || chr(10) || 'Inicio Erro (controller_update_request)';
                r_msg := r_msg || chr(10) || 'JSON: '||chr(10)||coalesce(w_json, p_sql);
                r_msg := r_msg || chr(10) || util.get_erro;
                r_msg := r_msg || chr(10) || 'Fim Erro (controller_update_request)';
                log_footer;
    end controller_update_request;
    
    /**
    Controle padrão para realizar as buscas
    
    Procedimento interno;
    <ul>
        <li>
            call_request: realizando a chamada da requisição
            <ul>
                <li>
                    p_json type pljson: json utilizado para compor o metodo da requisição
                </li>
            </ul>
        </li>
    </ul>
    @param  p_sql       json ou select a ser realizado a busca
    @param  p_method    metodo de busca da rquisição desejada
    @param  p_ds_entity descrição da entidade
    @param  p_entity    nome da entidade
    @param  p_nm_table  nome da tabela
    @param  p_template  json template
    @param  r_msg       mensagem de retorno (log)
    
    @return retorna o objeto pljson_list. 
*/
    function controller_find(p_sql varchar2, p_method in varchar2, p_ds_entity in varchar2, p_entity in varchar2, p_template in varchar2, r_msg out clob) return pljson_list is
    
--        wMSG        clob;
        jl_lista    pljson_list;
        json_tmp    pljson;
        w_json      varchar2(4000);      
        is_json     boolean;
        json_answer pljson_list;
        
        
        procedure call_request(p_json pljson) is
            l_variables      varchar2(100);
            v_json           pljson;
            v_json_char      clob;
            v_nm_method      varchar2(300);
            v_chave          varchar2(100);
            v_set            varchar2(100);
            v_resposta       clob;
            v_msg            clob;
        begin
            v_json_char := upper(p_json.to_char(false));                --converter objeto json list em char
            v_json_char := replace(v_json_char, 'null', '""');          --se valor da coluna null converter para ""
            v_json      := util_remove_empty_column(json(v_json_char)); --remover colunas vazias
            
            util_extract_from_template(v_nm_method, v_chave, v_set, lower(p_method), p_template, v_json, p_entity);
            v_resposta := service_find_by(v_nm_method, v_msg, false);
            r_msg := r_msg || chr(10) || v_msg;
            if substr(v_resposta,1,1) = '[' then 
                json_answer := pljson_list(v_resposta);
            else 
                json_answer := pljson_list('['||v_resposta||']');
            end if;
--                controller_save_request(js_cursos, 'courses', 'Cursos', 'course', 'canvas_cursos', json_template_course, is_batch, p_verify_id, w_msg, 'courses?account_id=118&search_term=<sis_course_id>'); --'users?search_term=<sis_user_id>'
----                r_msg := r_msg || chr(10) || w_msg;
--                service_save_request(p_sql, w_function||'/create', w_key, w_update, p_nm_table, is_batch, w_msg);
            
        end;
    begin
    
        begin
            is_json := true;
            json_tmp := pljson(p_sql);
            exception 
                when others then
                    is_json := false;
        end;
    
        if is_json then
            w_json := json_tmp.to_char;
            if util_validate_json(p_template, w_json) then
                r_msg := r_msg || chr(10) || 'Consultar '||p_ds_entity||' => '||p_sql;
                call_request(json_tmp);
            else
                raise e_formato_json_invalido;
            end if;
        else
            r_msg := r_msg || chr(10) || 'Converter sql em lista de json';
            jl_lista := JSON_UTIL_PKG.SQL_TO_JSON(p_sql);
            r_msg := r_msg || chr(10) || 'Quantidade: '||jl_lista.count;
            for i in 1..jl_lista.count loop
                w_json := jl_lista.get(i).to_char;
                if util_validate_json(p_template, w_json) and i = 1 then
                    call_request(pljson(w_json));
                else
                    raise e_formato_json_invalido;
                end if;
            end loop;
        end if;
        
        return coalesce(json_answer, null);
        exception
            when e_formato_json_invalido then
                r_msg := r_msg || chr(10) || 'Inicio Erro';
                r_msg := r_msg || chr(10) || replace(msg_e_formato_json_invalido, 'dado', w_json);
                r_msg := r_msg || chr(10) || 'Fim Erro';
                return null;
            when others then
                r_msg := r_msg || chr(10) || 'Inicio Erro';
                r_msg := r_msg || chr(10) || util.get_erro;
                r_msg := r_msg || chr(10) || 'Fim Erro';
                return null;
    end controller_find;
    
    procedure controller_update_canvas_ins(p_sql in varchar2, p_method in varchar2, p_ds_entity in varchar2, p_entity in varchar2, p_nm_table in varchar2, p_template in varchar2, r_msg out clob) is
        
        w_qt             number;
        w_msg            clob;
        w_json_list      pljson_list;
        
        
        procedure log_footer is
        begin
            if w_qt > 0 then
                r_msg := r_msg || chr(10) || 'Atualizado: '||TO_CHAR(w_qt);
            end if;
            r_msg := r_msg || chr(10) || 'Fim do metodo: '||p_method;
        end;
    begin
        
        
        r_msg := 'Inicio do método: '||p_method;
        r_msg := r_msg || chr(10) || 'Buscar:' || p_ds_entity;
        w_json_list := controller_find(p_sql, p_method, p_ds_entity, p_entity, p_template, w_msg);
        if w_json_list.count > 0 then
            r_msg := r_msg || chr(10) || 'Quantidade:' || to_char(w_json_list.count);
            for i in 1..w_json_list.count loop
                --verificar como irei atualziar as tabelas
            null;
            end loop;
        end if;
        
        log_footer;
        exception
            when others then
                r_msg := r_msg || chr(10) || w_msg;
                r_msg := r_msg || chr(10) || 'Inicio Erro (controller_update_table)';
                r_msg := r_msg || chr(10) || '?:'||chr(10)||coalesce(w_json_list.to_char, p_sql);
                r_msg := r_msg || chr(10) || util.get_erro;
                r_msg := r_msg || chr(10) || 'Fim Erro (controller_update_table)';
                log_footer;
    end controller_update_canvas_ins;
    
/**
    Objetivo: atualizar a tabela canvas conforme retorno, se basendo no template informado
    
    @param  p_sql       json ou select a ser realizado a busca
    @param  p_method    metodo de busca da rquisição desejada
    @param  p_ds_entity descrição da entidade
    @param  p_entity    nome da entidade
    @param  p_nm_table  nome da tabela
    @param  p_template  json template
    @param  r_msg       mensagem de retorno (log)
    
*/
    procedure controller_update_table(p_sql in varchar2, p_method in varchar2, p_ds_entity in varchar2, p_entity in varchar2, p_nm_table in varchar2, p_template in varchar2, r_msg out clob) is
        
        w_qt             number;
        w_msg            clob;
        w_json_list      pljson_list;
        w_json           varchar2(3000);
        
        procedure find_and_update(p_json varchar2) is
            v_result pljson_list;
            v_json pljson;
            v_method varchar2(300);
            v_pagina number;
            
            procedure buscar(pagina number) is
                
            begin
                r_msg := r_msg || chr(10) || '--------------------------------------------------';
                v_method := replace(p_method, '<page>', to_char(pagina));
                r_msg := r_msg || chr(10) || 'Inicio do método: '||v_method;
                v_result := controller_find(p_json, v_method, p_ds_entity, p_entity, p_template, w_msg);
                r_msg := r_msg || chr(10) || w_msg;
                --r_msg := r_msg || chr(10) || 'sis-user-id:' || p_json;
                --r_msg := r_msg || chr(10) || 'v_result:' || v_result.to_char;
                --util_insert_log(r_msg, 'CANVAS_INSCRICOES', 'UPDATE TABLE CANVAS_INSCRICOES (CONTROLLER_UPDATE_TABLE)');
            end;
            
            procedure atualizar is
            begin
                if v_result is not null then
                    if v_result.count > 0 then
                        r_msg := r_msg || chr(10) || 'Quantidade:' || to_char(v_result.count);
                        for i in 1..v_result.count loop
                            --r_msg := r_msg || chr(10) || v_result.get(i).to_char;
                            --v_json := pljson(v_result.get(i).to_char);
                            w_msg := '';
                            service_update_table_canvas(v_result.get(i).to_char, v_method, p_nm_table, p_entity, p_template, w_msg);
                            r_msg := r_msg || chr(10) || w_msg;
                            --util_insert_log(r_msg, 'CANVAS_INSCRICOES', 'UPDATE TABLE CANVAS_INSCRICOES (CONTROLLER_UPDATE_TABLE)');
                            --if util_execute_sql('update canvas_inscricoes set state = ''' || v_json.get('state').str || ''', dt_updt = sysdate where canvas_id = ' || v_json.get('id').str || ' and state != ''' || v_json.get('state').str||'''', w_msg) then
                            --    util.p('atualizado com sucesso');
                            --else
                            --    util.p('não atualizado');
                            --end if;
                        end loop;
                    end if;
                end if;
            end;
            
        begin
            r_msg := r_msg || chr(10) || 'Buscar:' || p_ds_entity;
            v_pagina := 1;
            
            buscar(v_pagina);
            atualizar;
            while v_result is not null and v_result.count > 0 and p_method like '%page%' loop --and v_pagina <= 5
                v_pagina := v_pagina + 1;
                buscar(v_pagina);
                atualizar;
            end loop;
            
            
            r_msg := r_msg || chr(10) || '--------------------------------------------------';
        end;
        
        procedure log_footer is
        begin
            if w_qt > 0 then
                r_msg := r_msg || chr(10) || 'Atualizado: '||TO_CHAR(w_qt);
            end if;
        end;
    begin
    
        r_msg := r_msg || chr(10) || 'Converter sql em lista de json';
        w_json_list := JSON_UTIL_PKG.SQL_TO_JSON(p_sql);
        --r_msg := r_msg || chr(10) || 'Quantidade: '||w_json_list.count;
        for i in 1..w_json_list.count loop
            w_json := w_json_list.get(i).to_char;
            if i = 1 then
                if util_validate_json(p_template, w_json) then
                    find_and_update(w_json);
                else
                    raise e_formato_json_invalido;
                end if;
            else
                find_and_update(w_json);
            end if;
        end loop;
        
        
        /*r_msg := 'Inicio do método: '||p_method;
        r_msg := r_msg || chr(10) || 'Buscar:' || p_ds_entity;
        w_json_list := controller_find(p_sql, p_method, p_ds_entity, p_entity, p_template, w_msg);
        if w_json_list is not null then
            if w_json_list.count > 0 then
                r_msg := r_msg || chr(10) || 'Quantidade:' || to_char(w_json_list.count);
                for i in 1..w_json_list.count loop
                    w_json_list.get(i).print;
                    --verificar como irei atualziar as tabelas
                end loop;
            end if;
        end if;*/
        
        log_footer;
        exception
            when e_formato_json_invalido then
                r_msg := r_msg || chr(10) || w_msg;
                r_msg := r_msg || chr(10) || 'Inicio Erro (controller_update_table)(e_formato_json_invalido)';
                r_msg := r_msg || chr(10) || replace(msg_e_formato_json_invalido, 'dado', w_json);
                r_msg := r_msg || chr(10) || 'Fim Erro (controller_update_table)(e_formato_json_invalido)';
                log_footer;
            when others then
                r_msg := r_msg || chr(10) || w_msg;
                r_msg := r_msg || chr(10) || 'Inicio Erro (controller_update_table)';
                --r_msg := r_msg || chr(10) || '?:'||chr(10)||coalesce(w_json_list.to_char, p_sql);
                r_msg := r_msg || chr(10) || util.get_erro;
                r_msg := r_msg || chr(10) || 'Fim Erro (controller_update_table)';
                --util_insert_log(r_msg, 'CANVAS_INSCRICOES', 'UPDATE TABLE CANVAS_INSCRICOES (ERRO)');
                log_footer;
    end controller_update_table;
    
/**
    Padronizar a forma de chamada de requisição de um delete.
    
    @param  p_sql       select a ser enviado.
    @param  p_method    metodo a ser utilizado na  chamada.
    @param  p_ds_entity descrição da entidade a ser chamada (Usuário, Curso,..).
    @param  p_entity    nome da entidade (user, course, term, etc).
    @param  p_nm_table  nome da tabela que será atualizada no base oracle.
    @param  p_template  template padrão referente da entidade.
    @param  r_msg       <b>retorna</b> o log.
*/
    procedure controller_delete_request(p_sql in varchar2, p_method in varchar2, p_ds_entity in varchar2, p_entity in varchar2, p_nm_table in varchar2, p_template in varchar2, r_msg out clob) is
        
        w_qt             number;
        w_msg            clob;
        w_str_json       clob;
        w_json_list      pljson_list;
        w_o_json         pljson;
--        procedure call_request(p_json pljson) is
--            
--            l_sql             varchar2(200);
--            l_funcao          varchar2(100);
--            l_chave           varchar2(100);
--            l_update          varchar2(100);
--            l_o_json          pljson;
--            l_resposta        clob;
--                      
--        begin
--            l_o_json := p_json;
--            util_extract_from_template(l_funcao, l_chave, l_update, lower(p_method), p_template, l_o_json, null);
--                    
--            r_msg := r_msg || chr(10) || '"Deletar" '||p_ds_entity||', requisição individual: '||l_funcao;
--            l_resposta := call_request_delete(l_funcao, w_msg);
--            r_msg := r_msg || chr(10) || w_msg;
--            
--            if lower(w_msg) not like '%erro%' then
--                if l_update like '%<%' then
--                    r_msg := r_msg || chr(10) || 'before l_update:'||l_update;
--                    r_msg := r_msg || chr(10) || 'l_resposta:'||l_resposta;
--                    l_update := util_replace_tag(l_update, l_resposta);
--                    r_msg := r_msg || chr(10) || 'after l_update:'||l_update;
--                end if;
----            if call_request_delete(l_funcao, w_msg) then
--                w_qt := (w_qt + 1);
--                --l_sql := 'update '||p_nm_table||' set dt_updt = sysdate where '||l_chave; --to_date('''||to_char(sysdate, 'rrrr-mm-dd HH24:MI:SS')||''', ''rrrr-mm-dd HH24:MI:SS'')
--                l_sql := 'update '||p_nm_table||' set '||l_update||' where '||replace(l_chave, '%40', '@');
--                r_msg := r_msg || chr(10) || l_sql;
--                w_msg := '';
--                if not(util_execute_sql(l_sql, w_msg)) then
--                    r_msg := r_msg || chr(10) || w_msg;
--                    raise e_table_not_update;
--                else
--                    r_msg := r_msg || chr(10) || w_msg;
--                    r_msg := r_msg || chr(10) || 'Atualizou '||p_nm_table||' ('||l_chave||')';
--                end if;
--            else
--                raise e_not_deleted;
--            end if;
--        end call_request;
        
        procedure log_footer is
        begin
            if w_qt > 0 then
                r_msg := r_msg || chr(10) || 'Deletado: '||to_char(w_qt);
            end if;
            r_msg := r_msg || chr(10) || 'Fim do metodo delete';
        end;
    begin
        w_qt := 0;
        r_msg := 'Inicio do método delete: '||p_method;
        r_msg := r_msg || chr(10) || 'Deletar:' || p_ds_entity;
        
        if util_is_json(p_sql) then
            r_msg := r_msg || chr(10) || 'Converter StringJson em PLJSON';
            w_o_json := pljson(p_sql);
            r_msg := r_msg || chr(10) || 'Iniciar requisição individual';
            
            r_msg := r_msg || chr(10) || 'Preparando o PLJSON a ser enviado';
            w_str_json := controller_prepare_json(w_o_json, p_entity, p_template, true, w_msg);
            r_msg := r_msg || chr(10) || w_msg;

            r_msg := r_msg || chr(10) || 'Iniciar a chamada do serviço (service_delete_request)';
            service_delete_request(w_str_json, p_method, p_nm_table, p_entity, p_ds_entity, p_template, w_msg);
            r_msg := r_msg || chr(10) || w_msg;
        else
            
            r_msg := r_msg || chr(10) || 'Converter sql em lista de json';
            w_json_list := JSON_UTIL_PKG.SQL_TO_JSON(p_sql);
            r_msg := r_msg || chr(10) || 'Iniciar requisição em lote';
            r_msg := r_msg || chr(10) || 'Quantidade: '||w_json_list.count||'';
            
            for i in 1..w_json_list.count loop
                begin
                    r_msg := r_msg || chr(10) || '-----------------------------------------------------------------------------';
                    r_msg := r_msg || chr(10) || 'Preparando o PLJSON a ser enviado';
                    w_str_json := controller_prepare_json(pljson(w_json_list.get(i)), p_entity, p_template, true, w_msg);
                    r_msg := r_msg || chr(10) || w_msg;
                    r_msg := r_msg || chr(10) || w_str_json;
                    r_msg := r_msg || chr(10) || 'Chamada do serviço (service_delete_request)';
                    service_delete_request(w_str_json, p_method, p_nm_table, p_entity, p_ds_entity, p_template, w_msg);
                    r_msg := r_msg || chr(10) || w_msg;
                    w_qt := w_qt + 1;
                exception
                    when others then
                        r_msg := r_msg || chr(10) || w_msg;
                        r_msg := r_msg || chr(10) || 'Inicio Erro (controller_delete_request)';
                        r_msg := r_msg || chr(10) || 'SQL/JSON: '||chr(10)||coalesce(w_o_json.to_char, p_sql);
                        r_msg := r_msg || chr(10) || util.get_erro;
                        r_msg := r_msg || chr(10) || 'Fim Erro (controller_delete_request)';
                end;
            end loop;
        end if;
        log_footer;
        exception
            when others then
                r_msg := r_msg || chr(10) || w_msg;
                r_msg := r_msg || chr(10) || 'Inicio Erro (controller_delete_request)';
--                r_msg := r_msg || chr(10) || 'JSON: '||chr(10)||coalesce(w_o_json.to_char, p_sql);
                r_msg := r_msg || chr(10) || util.get_erro;
                r_msg := r_msg || chr(10) || 'Fim Erro (controller_delete_request)';
                log_footer;
    end controller_delete_request;
    
/**
    Foi criado esse controle pois o controle padrão 
    (controle_save_request) não atende a estrutura do curso.
    
    @param  p_sql       select a ser enviado.
    @param  is_batch    em lote.
    @param  p_verify_id verifica se o id ja existe no canvas.
    @param  r_msg       <b>retorna</b> o log.
    
*/
    procedure controller_save_curso(p_sql in varchar2, is_batch in boolean, p_verify_id in boolean,r_msg out clob) is
        w_course_id  varchar2(100);
        l_exist      boolean;
        js_cursos    clob;
        w_lista_json clob;
        w_msg        clob;
        w_msg2       clob;
        jl_cursos    pljson_list;
        l_courses    r_cursos;
        
        procedure atualizar_tabela(p_canvas_id varchar2, p_course_id varchar2) is
        begin
            r_msg := r_msg || chr(10) || 'update canvas_cursos set dt_incl = '||sysdate||', canvas_id = '||p_canvas_id||' where sis_course_id = '||p_course_id;
            update canvas_cursos set dt_incl = sysdate, canvas_id = p_canvas_id where sis_course_id = p_course_id;
            
            if sql%rowcount > 0 then
                r_msg := r_msg || chr(10) || 'Atualizou canvas_cursos ('||p_course_id||')';
            else
                raise e_curso_not_update;
            end if;
        end;
    begin
--        r_msg := 'Inicio - inserindo cursos';
        if lower(p_sql) like '%"course"%' then
            controller_save_request(util_all_atribute_to_upper(p_sql), 'courses', 'Cursos', 'course', 'canvas_cursos', json_template_course, is_batch, p_verify_id, w_msg, 'courses?account_id=118&search_term=<sis_course_id>'); --'users?search_term=<sis_user_id>'
            r_msg := r_msg || chr(10) || w_msg;
        else
            r_msg := r_msg || chr(10) || 'Converter sql em lista de json';
            jl_cursos := JSON_UTIL_PKG.SQL_TO_JSON(p_sql);
            r_msg := r_msg || chr(10) || 'Quantidade: '||jl_cursos.count;
--            if (is_batch) then
--                raise e_batch_not_found;
--            else
                r_msg := r_msg || chr(10) || 'Criar vários cursos, requisição individual: courses';
                
                for i in 1..jl_cursos.count loop
                    declare
                        l_variables varchar2(100);
                        js_curso    pljson;
                    begin
                        r_msg := r_msg || chr(10) || '-----------------------------------------------------------------------------';
                        js_cursos := jl_cursos.get(i).to_char(false);
                        js_cursos := replace(js_cursos, 'null', '""');
                        
                        js_curso := util_remove_empty_column(json(js_cursos));
--                        js_curso := json(js_cursos);
                        if js_curso.exist('PUBLISH') then
                            l_variables := ',"PUBLISH":';
                            if js_curso.get('PUBLISH').typeval = 5 then
                                if js_curso.get('PUBLISH').get_bool then
                                    l_variables := l_variables||'true';
                                else
                                    l_variables := l_variables||'false';
                                end if;
                            elsif js_curso.get('PUBLISH').typeval = 3 then
                                l_variables := l_variables||rtrim(js_curso.get('PUBLISH').str);
                            end if;
                            js_curso.remove('PUBLISH');
                        end if;
                        if js_curso.exist('IMPORT_CONTENT') then
                            l_variables := l_variables||',"IMPORT_CONTENT":';
                            if js_curso.get('IMPORT_CONTENT').typeval = 5 then
                                if js_curso.get('IMPORT_CONTENT').get_bool then
                                    l_variables := l_variables||'true';
                                else
                                    l_variables := l_variables||'false';
                                end if;
                            elsif js_curso.get('IMPORT_CONTENT').typeval = 3 then
                                l_variables := l_variables||js_curso.get('IMPORT_CONTENT').str;
                            end if;
                            js_curso.remove('IMPORT_CONTENT');
                        end if;
                        js_cursos := '{"COURSE":'||js_curso.to_char(false)||l_variables||'}';
                        l_exist := false;
                        if p_verify_id then
                            w_course_id := js_curso.get('SIS_COURSE_ID').STR;
                            r_msg := r_msg || chr(10) || 'Buscar curso ('||w_course_id||')';
                            w_msg := dao_find_all('courses?account_id=118&search_term='||w_course_id, r_msg => w_msg2);
                            r_msg := r_msg || chr(10) || w_msg2;
                            r_msg := r_msg || chr(10) || 'Resultado:'||w_msg;
                            l_courses := get_courses(w_msg);
                            for i in 1..l_courses.count loop
                                r_msg := r_msg || chr(10) || w_course_id || '='||UTIL.REMOVE_LINES(UTIL.REMOVE_ALL_SPECIAL_CHARACTER(l_courses(i).sis_course_id, keep_words));
                                if w_course_id = UTIL.REMOVE_LINES(UTIL.REMOVE_ALL_SPECIAL_CHARACTER(l_courses(i).sis_course_id, keep_words)) then
                                    r_msg := r_msg || chr(10) || 'Curso já existe ('||w_course_id||')';
                                    atualizar_tabela(UTIL.REMOVE_LINES(UTIL.REMOVE_ALL_SPECIAL_CHARACTER(l_courses(i).canvas_id, keep_words)), w_course_id);
                                    l_exist := true;
                                end if;
                            end loop;
                        end if;
                        if not l_exist then
--                            if not(util_validate_json(json_template_course, js_cursos)) and i = 1 then
--                                raise e_formato_json_invalido;
--                            else
                            if is_batch then--TODO aqui ainda não foi finalizado
                                if  jl_cursos.count = i then
                                    w_lista_json := w_lista_json ||','||util_all_atribute_to_lower(js_cursos)||']';
                                elsif w_lista_json is not null then
                                    w_lista_json := w_lista_json|| ','||util_all_atribute_to_lower(js_cursos);
                                else
                                    w_lista_json := '['||util_all_atribute_to_lower(js_cursos);
                                end if;
                            else
                                controller_save_request(js_cursos, 'courses', 'Cursos', 'course', 'canvas_cursos', json_template_course, is_batch, p_verify_id, w_msg, 'courses?account_id=118&search_term=<sis_course_id>'); --'users?search_term=<sis_user_id>'
                                r_msg := r_msg || chr(10) || w_msg;
                            end if;
--                            end if;
                        end if;
                    exception
                        when e_curso_not_update then
                            r_msg := r_msg || chr(10) || replace(msg_e_curso_not_update, 'dado', '');
                        when e_formato_json_invalido then
                            r_msg := r_msg || chr(10) || replace(msg_e_formato_json_invalido, 'dado', js_cursos);
                            exit;
                        when others then
                            r_msg := r_msg || chr(10) || 'Inicio Erro:';
                            r_msg := r_msg || chr(10) || util.get_erro;
                            r_msg := r_msg || chr(10) || 'Fim Erro';
                    end;
                end loop;
                if is_batch and upper(r_msg) not like '%ERRO%' then
                    controller_save_request(w_lista_json, 'courses', 'Cursos', 'course', 'canvas_cursos', json_template_course, is_batch, p_verify_id, w_msg, 'courses?account_id=118&search_term=<sis_course_id>'); --'users?search_term=<sis_user_id>'
                    r_msg := r_msg || chr(10) || w_msg;
                end if;
--                r_msg := r_msg || chr(10) || 'Inserido: '||qt_inserido;
--            end if;
        end if;
        r_msg := r_msg || chr(10) || 'Fim - inserindo cursos';
        exception
            when e_batch_not_found then
                r_msg := r_msg || chr(10) || replace(msg_e_batch_not_found, 'dado', '');
                r_msg := r_msg || chr(10) || 'Fim - inserindo cursos';
            when e_formato_json_invalido then
                r_msg := r_msg || chr(10) || replace(msg_e_formato_json_invalido, 'dado', js_cursos);
                r_msg := r_msg || chr(10) || 'Fim - inserindo cursos';
            when others then
                r_msg := r_msg || chr(10) || 'Inicio Erro:';
                r_msg := r_msg || chr(10) || util.get_erro;
                r_msg := r_msg || chr(10) || 'Fim Erro';
                r_msg := r_msg || chr(10) || 'Fim - inserindo cursos';
    end;
    

    /***************************Fim Controller*********************************/
    
    /***************************Inicio Usuário*********************************/
/**
    Retornar todos os usuários e/ou conforme parâmetros.
    
    @param  p_page          (opcional) pagina a retornar, se não informado passar 1.
    @param  p_per_page:     (opcional) quantidade por pagina.
    @param  p_account_id    (opcional) ID da conta / sub - conta onde você quer para listar os usuários. Se o parâmetro não é enviado, por padrão, a conta root é assumido.
    @param  p_search_term   (opcional) Sequência de caracteres (pelo menos 3), para ser utilizado como padrão de busca em SIS_ID dados, nome, login_id ou e-mail. 

    @return json.
*/
    function usr_find_all(p_page varchar2 default '1', p_per_page varchar2 default null, p_account_id varchar2 default null, p_search_term varchar2 default null) return clob is
    --page=1&per_page=100&account_id=1&search_term=ctec
        p_parametros varchar2(1000);
        w_msg clob;
    begin
        p_parametros := '?page='||p_page||case when coalesce(p_per_page, '') = p_per_page then ',&per_page='||p_per_page end || case when coalesce(p_account_id, '') = p_account_id then ',&account_id='||p_account_id end || case when coalesce(p_search_term, '') = p_search_term then ',&search_term='||p_search_term end;
        return dao_find_all('users?', r_msg => w_msg);
    end usr_find_all;
    
    
/**
    Buscar usuário pelo id.

    @param  p_sis_user_id   ID interno do sistema acadêmico (SIS) atribuído ao usuário.

    @return formato json.    
*/
    function usr_find_by_id(p_sis_user_id varchar2) return varchar2 is
        w_msg clob;
    begin
        return dao_find_all('users', '/sis_user_id:'||p_sis_user_id, r_msg => w_msg);
    end usr_find_by_id;
    
/**
    Retornar lista de usuarios de uma lista de json.
    
    @param  p_json_usuarios json contendo os usuários.
    
    @return r_usuarios  lista de records criado no spec deste pacote.
*/
    function get_users(p_json_usuarios clob) return r_usuarios as
        
        w_json_usuarios clob;
        j_usuarios      pljson_list;
        j_usuario       pljson;
        w_json          pljson;
        w_usuarios      r_usuarios;
        w_dados         r_r_dados;
        
        function popular_usuario(p_usuario pljson) return canvas_usuarios%rowtype is
            w_usuario canvas_usuarios%rowtype;
            w_dados   r_dados;
            procedure try(p_nm_property varchar2) is
            begin
                if p_nm_property = 'id' then
                    w_usuario.canvas_id     := w_dados(p_nm_property).valor;
                elsif p_nm_property = 'short_name' then
                    w_usuario.short_name    := w_dados(p_nm_property).valor;
                elsif p_nm_property = 'sortable_name' then    
                    w_usuario.sortable_name := w_dados(p_nm_property).valor;
                elsif p_nm_property = 'login_id' then
                    w_usuario.login         := w_dados(p_nm_property).valor;
                elsif p_nm_property = 'sis_user_id' then
                    w_usuario.sis_user_id   := w_dados(p_nm_property).valor;
                elsif p_nm_property = 'email' then
                    w_usuario.email         := w_dados(p_nm_property).valor;
--                elsif p_nm_property = 'last_login' then
--                    w_usuario.last_login    := w_dados(p_nm_property).valor;
                end if;
                exception
                    when others then
                        null;
            end;
        begin
            w_dados := get_result(p_usuario.to_char(false));
            try('id');
            try('short_name');
            try('sortable_name');
            try('login_id');
            try('sis_user_id');
            try('email');
--            try('last_login');
            return w_usuario;
        end;
        
    begin
        w_json := get_default_json(p_json_usuarios, 'users');--json(w_json_usuarios);
        if w_json.count > 1 then
            j_usuarios := pljson_list(w_json.get('users'));
            for i in 1.. j_usuarios.count loop
                j_usuario := pljson(j_usuarios.get(i));
                w_usuarios(i) := popular_usuario(j_usuario);
            end loop;
        else
--            w_json.print(false);
            w_usuarios(1) := popular_usuario(w_json);
        end if;
        return w_usuarios;
    end;
    
    
    
/**
    Atualizar usuário conforme id, ou conforme sql
    no sql deve existir a coluna USER_ID, será executado em lote
    
    @param  p_json  pode ser sql, nesse caso id não é obrigatorio.
    @param  r_msg   <b>retorna</b> o log.
*/
    procedure view_usr_atualizar(p_sql varchar2, r_msg out clob) as    
        w_msg         clob;
    begin
            controller_update_request(p_sql, 'users/<user_id>', 'Usuário', 'user', 'canvas_usuarios', json_template_updt_user, w_msg); --'USER_ID', 
            r_msg := r_msg || chr(10) || w_msg;
    end view_usr_atualizar;
    
/**
    Criar usuários, envio individual ou em lote, utilize o parametro
    is_batch para informar se será envio em lote.
    
    @param  p_sql           sql que contém os dados do usuário ou json de usuário (formatar para apenas 1).
    @param  is_batchtrue    requisição em lote, false = requisição individual.
    @param  p_verify_id     buscar id do usuário no canvas caso true.
    @param  r_msg   <b>retorna</b> o log.
    
*/
    procedure view_usr_salvar(p_sql varchar2, r_msg out clob, is_batch boolean default false, p_verify_id boolean default false) as
        w_msg clob;
    begin
        controller_save_request(p_sql => p_sql, p_method => 'users', p_ds_entity => 'Usuário', p_entity => 'user', p_nm_table => 'canvas_usuarios', p_template => json_template_user, is_batch => is_batch, p_verify_id => p_verify_id, r_msg => w_msg, p_method_find => 'users/sis_user_id:<sis_user_id>'); --'users?search_term=<sis_user_id>'
        r_msg := r_msg || chr(10) || w_msg;
    end view_usr_salvar;
    
/**
    Retornar ou exibir todos os usuários. 
    
    @param    exibir_json exibe em DBMS o json retornado.
    
    @return   r_usuarios.
*/
    function view_all_usrs(exibir_json boolean default false) return r_usuarios is
        w_json_usuarios clob;
    begin
        w_json_usuarios := usr_find_all;
        if exibir_json then 
            declare
                geral pljson;
                lista pljson_list;
                tmp   pljson;
            begin
                geral := pljson('{"show": '||w_json_usuarios||'}');
                
--                geral.print(false);
                lista := pljson_list(geral.get('show'));
                util.p('Quantidade de usuários:'||lista.count);
                for i in 1..lista.count loop
--                    tmp := service_remove_empty_column(json(lista.get(i)));
                    util.p('('||i||')----------------------------------------------------------------------------------');
                    lista.get(i).print(false);
--                    tmp.print(false);
                    util.p('('||i||')----------------------------------------------------------------------------------');
                end loop;
            end;
        end if;
        
        return get_users(w_json_usuarios);
        
    end;
    
    
/**
    Retornar ou exibir o usuário, buscando pelo sis_user_id. 
    
    @param  p_sis_user_id   id do usuário a buscar.
    @param  exibir_json     exibe em DBMS o json retornado.
    
    @return r_usuario.
*/
    function view_usr_by_id(p_sis_user_id varchar2,exibir_json boolean default false) return canvas_usuarios%rowtype is
        w_json_usuario clob;
    begin
        w_json_usuario := usr_find_by_id(p_sis_user_id);
        if exibir_json then 
            declare
                geral pljson;
            begin
                geral := pljson('{"show": '||w_json_usuario||'}');
                geral.print(false);    
            end;
        end if;
        return get_users(w_json_usuario)(1);
    end;

    /**************************Termino Usuário*********************************/
 
    /**************************Inicio Curso************************************/
    
/**
    Retornar lista de cursos de uma lista de json.
    
    @param    p_json  json contendo os cursos.
    
    @return   r_cursos    lista de record criado no spec deste pacote.
*/
    function get_courses(p_json clob) return r_cursos as
        
        j_cursos pljson_list;
        j_curso  pljson;
        w_json   pljson;
        w_cursos r_cursos;
        
        function popular_curso(p_json pljson) return r_curso is
            w_curso r_curso;
            w_dados r_dados;
            
            procedure try(p_nm_property varchar2) is
            begin
                if p_nm_property = 'id' then
                    w_curso.canvas_id       := w_dados(p_nm_property).valor;
                elsif p_nm_property = 'sis_course_id' then
                    w_curso.sis_course_id   := w_dados(p_nm_property).valor;
                elsif p_nm_property = 'name' then
                    w_curso.name            := w_dados(p_nm_property).valor;
                elsif p_nm_property = 'code' then
                    w_curso.code            := w_dados(p_nm_property).valor;
                elsif p_nm_property = 'status' then
                    w_curso.status          := w_dados(p_nm_property).valor;
                elsif p_nm_property = 'account_id' then
                    w_curso.account_id      := w_dados(p_nm_property).valor;
                elsif p_nm_property = 'start_at' then
                    w_curso.start_at        := w_dados(p_nm_property).valor;
                elsif p_nm_property = 'end_at' then
                    w_curso.end_at          := w_dados(p_nm_property).valor;
                end if;
                exception
                    when others then
                        null;
            end;
        begin
            w_dados := get_result(p_json.to_char(false));
            try('id');
            try('sis_course_id');
            try('name');
            try('code');
            try('status');
            try('account_id');
            try('start_at');
            try('end_at');
            return w_curso;
        end;
    begin
    
        w_json := get_default_json(p_json, 'courses');
--        if w_json.get('courses').count > 1 then
            j_cursos := pljson_list(w_json.get('courses'));
            for i in 1.. j_cursos.count loop
                j_curso := pljson(j_cursos.get(i));
                w_cursos(i) := popular_curso(j_curso);
            end loop;
--        else
--            w_cursos(1) := popular_curso(w_json);
--        end if;
        return w_cursos;
    end;
    
    /** mostrar todos os cursos  */
    function view_all_crs(exibir_json boolean default false) return r_cursos is
--        w_cursos r_periodos_academico;
        w_msg clob;
    begin
        return get_courses(service_find_by('courses?sis_term_id=20181.GRAD.06', w_msg, exibir_json));
    end;
    
/**
    Criar cursos, envio individual ou em lote, utilize o parametro
    is_batch para informar se será envio em lote.
    obs: Para envido em lote p_sql deve sem um "select".
    
    Funções;<br/>
         call_request:<br/>
             objetivo: chamar a requisição de criação<br/>
             Parametro:<br/>
                 p_json: formato json (seguir template)<br/>
                 p_method: metodo da requisição<br/>
                 p_is_batch: true = em lote<br/>
             Retorno:<br/>
                 r_msg: log<br/>
    
    @param  p_sql       sql que contém os dados/json do curso (formatar para apenas 1, quando json).
    @param  is_batch    true = requisição em lote, false = requisição individual.
    @param  r_msg       <b>retorna</b> o log.
*/
    procedure view_crs_salvar(p_sql varchar2, r_msg out clob, is_batch boolean default false, p_verify_id boolean default false) as
        w_msg       clob;
    begin
        controller_save_curso(p_sql, is_batch, p_verify_id, w_msg);
        r_msg := r_msg || chr(10) || w_msg;
    end view_crs_salvar;
  
    procedure view_crs_atualizar(p_sql varchar2, r_msg out clob) as
        w_msg         clob;
    begin
        controller_update_request(p_sql, 'courses/sis_course_id:<old_sis_course_id>', 'Curso', 'course', 'canvas_cursos', json_template_updt_course, w_msg);
        r_msg := r_msg || chr(10) || w_msg;
    end view_crs_atualizar;
    
    procedure view_crs_liberar_eliminar(p_sql varchar2, r_msg out clob) as
        w_msg         clob;
    begin
        controller_delete_request(p_sql, 'courses/sis_course_id:<sis_course_id>/release', 'Curso', 'course_release', 'CANVAS_CURSOS_EXCL', json_template_elim_course, w_msg);
        r_msg := r_msg || chr(10) || w_msg;
    end view_crs_liberar_eliminar;
    
    procedure view_crs_update_table(p_sql varchar2, r_msg out clob) is
        w_msg clob;
        w_resposta pljson_list;
    begin
        --page=<page>&per_page=50&state%5B%5D=active&state%5B%5D=inactive&state%5B%5D=invited&state%5B%5D=deleted&state%5B%5D=creation_pending&state%5B%5D=rejected&state%5B%5D=complet
        controller_update_table(p_sql, 'courses/sis_course_id:<sis_course_id>', 'Cursos', null, 'canvas_cursos', json_temp_updt_table_course, w_msg);
        r_msg := r_msg || chr(10) || w_msg;
        
        insert into canvas_log
                       (nm_table
                       ,ds_log
                       ,nm_metodo)
                 values('CANVAS_CURSOS'
                       ,r_msg
                       ,'UPDATE TABLE CANVAS_CURSOS(CONTROLLER_UPDATE_TABLE)');
    end;
    
    /**************************Termino Curso***********************************/
    
    /*********************Inicio Períodos Acadêmicos***************************/
    function get_tems_by_json(p_json clob) return r_periodos_academico is
        
        w_periodos_academico r_periodos_academico;
        
        w_json_str   clob;
        j_academicos pljson_list;
        j_academico  pljson;
        w_json       pljson;
        
        function popular(p_json2 pljson) return r_periodo_academico is
            w_dados     r_dados;
            w_academico r_periodo_academico;
            
            procedure try(p_nm_property varchar2) is
            begin
                
                if p_nm_property = 'id' then
                    w_academico.canvas_id := util.KEEP_NUMBER(w_dados(p_nm_property).valor);--to_number(util.REMOVE_LINES(replace(w_valores(j).valor, '"', '')));
                elsif p_nm_property = 'name' then
                    w_academico.name := w_dados(p_nm_property).valor;
                elsif p_nm_property = 'sis_term_id' then
                    w_academico.sis_term_id := w_dados(p_nm_property).valor;
                elsif p_nm_property = 'start_at' then
                    w_academico.start_at := util_str_to_date(w_dados(p_nm_property).valor);
                elsif p_nm_property = 'end_at' then
                    w_academico.end_at := util_str_to_date(w_dados(p_nm_property).valor);
                elsif p_nm_property = 'state' then
                    w_academico.state := w_dados(p_nm_property).valor;
                end if;
                exception
                    when others then
                        null;
            end;
            
        begin
            w_dados := get_result(p_json2.to_char(false));
            try('id');
            try('name');
            try('sis_term_id');
            try('start_at');
            try('end_at');
            try('state');
            return w_academico;
        end;
        
    begin
        w_json := get_default_json(p_json, 'terms');
        if w_json.count >= 1 then
            j_academicos := pljson_list(w_json.get('terms'));
            for i in 1.. j_academicos.count loop
                j_academico := pljson(j_academicos.get(i));
                w_periodos_academico(i) := popular(j_academico);
            end loop;
        else
            w_periodos_academico(1) := popular(w_json);
        end if;
        return w_periodos_academico;
    end;
    
    /** mostrar todos os período academicos */
    function view_all_aca(exibir_json boolean default false) return r_periodos_academico is
        w_periodos_academico r_periodos_academico;
        w_msg clob;
    begin
        return get_tems_by_json(service_find_by('terms?', w_msg, exibir_json));
    end;
    
    /** salvar período academicos */
    procedure view_aca_salvar(p_sql varchar2, r_msg out clob, is_batch boolean default false, p_verify_id boolean default false) as
        w_msg       clob;
    begin
        controller_save_request(p_sql, 'terms', 'Período Academico', 'term', 'canvas_periodos_academico', json_template_term, is_batch, p_verify_id, w_msg, p_method_find => 'terms?state=all');
        r_msg := r_msg || chr(10) || w_msg;
    end view_aca_salvar;

    /** atualizar período academicos */
    procedure view_aca_atualizar(p_sql varchar2, r_msg out clob) as
        w_msg         clob;
    begin
        controller_update_request(p_sql, 'terms/sis_term_id:<sis_term_id>', 'Período Academico', 'term', 'canvas_periodos_academico', json_template_updt_term, w_msg);
        r_msg := r_msg || chr(10) || w_msg;
    end view_aca_atualizar;
    
    /*********************Termino Períodos Acadêmicos**************************/
    
    procedure view_check_all_table(p_nm_table varchar2 default 'ALL') is
        /**PERIODO ACADEMICO*/
        cursor c_periodo_academico_save is
            select *
              from canvas_periodos_academico
             where canvas_id is null
               and dt_incl   is null;
        
        cursor c_periodo_academico_update is
            select *
              from canvas_periodos_academico
             where canvas_id is not null
               and dt_updt   is null;
        
        /**USUARIOS*/
        cursor c_usuarios_save is
            select *
              from canvas_usuarios
             where canvas_id is null
               and dt_incl   is null;
                
        cursor c_usuarios_update is
            select *
              from canvas_usuarios
             where canvas_id is not null
               and dt_updt   is null;

        /**CURSOS*/
        cursor c_cursos_save is
            select *
              from canvas_cursos
             where canvas_id is null
               and dt_incl   is null;
                
        cursor c_cursos_update is
            select *
              from canvas_cursos
             where canvas_id is not null
               and dt_updt   is null;
               
        r_periodos_academico canvas_periodos_academico%rowtype;
        qt number;
    begin
--        if p_nm_table = 'ALL' or p_nm_table = 'CANVAS_PERIODOS_ACADEMICO' then
--            util.p('--CANVAS_PERIODOS_ACADEMICO--');
--            qt := 1;
--            open c_periodos_academico_save;
--            fetch c_periodos_academico_save into r_periodos_academico;
--            loop
--                
--                fetch c_periodos_academico_save into r_periodos_academico;
--            exit when c_periodos_academico_save%found;
--                qt := qt + 1;
--            end loop;
--            
--            close c_periodos_academico_save;
--        end if;  
    null;

    end;
    
    /**************************Inicio Seções***********************************/
    function get_secoes(p_json clob) return r_secoes is
        
        w_secoes    r_secoes;
        w_json_str  clob;
        jl          pljson_list;
        j           pljson;
        w_json      pljson;
        
        function popular(p_json2 pljson) return r_secao is
            w_dados r_dados;
            w_secao r_secao;
            
            procedure try(p_nm_property varchar2) is
            begin
                
                if p_nm_property = 'id' then
                    w_secao.canvas_id := util.KEEP_NUMBER(w_dados(p_nm_property).valor);--to_number(util.REMOVE_LINES(replace(w_valores(j).valor, '"', '')));
                elsif p_nm_property = 'sis_section_id' then
                    w_secao.sis_section_id := w_dados(p_nm_property).valor;
                elsif p_nm_property = 'name' then
                    w_secao.name := w_dados(p_nm_property).valor;
                elsif p_nm_property = 'course_id' then
                    w_secao.course_id := util.KEEP_NUMBER(w_dados(p_nm_property).valor);
                elsif p_nm_property = 'sis_course_id' then
                    w_secao.code := w_dados(p_nm_property).valor;
                elsif p_nm_property = 'start_at' then
                    w_secao.start_at := util_str_to_date(w_dados(p_nm_property).valor);
                elsif p_nm_property = 'end_at' then
                    w_secao.end_at := util_str_to_date(w_dados(p_nm_property).valor);
                end if;
                exception
                    when others then
                        null;
            end;
            
        begin
            w_dados := get_result(p_json2.to_char(false));
            try('id');
            try('sis_section_id');
            try('name');
            try('course_id');
            try('sis_course_id');
            try('start_at');
            try('end_at');
            return w_secao;
        end;
        
    begin
        w_json := get_default_json(p_json, 'sections');
        if w_json.count > 1 then
            jl := pljson_list(w_json.get('sections'));
            for i in 1.. jl.count loop
                j := pljson(jl.get(i));
                w_secoes(i) := popular(j);
            end loop;
        else
            w_secoes(1) := popular(w_json);
        end if;
        return w_secoes;
    end get_secoes;
    
    /** salvar seções */
    procedure view_scs_salvar(p_sql varchar2, r_msg out clob, is_batch boolean default false, p_verify_id boolean default false) is
        w_msg clob;
    begin
        controller_save_request(p_sql, 'courses/sis_course_id:<sis_course_id>/sections', 'Seções', 'course_section', 'canvas_secoes', json_template_section, is_batch, p_verify_id, w_msg, p_method_find => 'sections/sis_section_id:<sis_section_id>');--courses/sis_section_id:
        r_msg := r_msg || chr(10) || w_msg;
    end view_scs_salvar;
    
    /** atualizar seções */
    procedure view_scs_atualizar(p_sql varchar2, r_msg out clob) as
        w_msg clob;
    begin
        controller_update_request(p_sql, 'sections/sis_section_id:<old_sis_section_id>', 'Seções', 'course_section', 'canvas_secoes', json_template_updt_section, w_msg); --'old_sis_section_id', 
        r_msg := r_msg || chr(10) || w_msg;
    end view_scs_atualizar;
    
    procedure view_scs_liberar_eliminar(p_sql varchar2, r_msg out clob) as
        w_msg         clob;
    begin
        controller_delete_request(p_sql, 'sections/sis_section_id:<sis_section_id>/release', 'Seções', 'course_section_release', 'CANVAS_SECOES_EXCL', json_template_elim_section, w_msg);
        r_msg := r_msg || chr(10) || w_msg;
    end view_scs_liberar_eliminar;
    
    /** buscar todas as seções */
    function view_all_scs(p_sis_course_id varchar2, exibir_json boolean default false) return r_secoes is
        w_msg clob;
    begin
        --courses/sis_course_id:<sis_course_id>/sections?include=<include>"
        return get_secoes(service_find_by('courses/sis_course_id:'||p_sis_course_id||'/sections?', w_msg, exibir_json));
    end;
    /**************************Termino Seções**********************************/
    
    /**************************Inicio Inscrições*******************************/
    /** salvar inscrições */
    procedure view_ins_salvar(p_sql varchar2, r_msg out clob, is_batch boolean default false) is
        w_msg clob;
    begin
--        controller_save_request(p_sql, 'sections/sis_section_id:<sis_section_id>/enrollments', 'Inscrições', 'enrollment', 'canvas_inscricoes', json_template_enrollment, is_batch, false, w_msg, p_method_find => 'enrollments/<enrollment_id>');
        controller_save_ins(p_sql, 'sections/sis_section_id:<sis_section_id>/enrollments', 'Inscrições', 'enrollment', 'canvas_inscricoes', json_template_enrollment, is_batch, false, w_msg, p_method_find => 'enrollments/<enrollment_id>');
        r_msg := r_msg || chr(10) || w_msg;
    end view_ins_salvar;
    
    /** atualizar inscrições */
    procedure view_ins_atualizar(p_sql varchar2, r_msg out clob) as
        w_msg clob;
    begin
--        controller_update_request(p_sql, 'courses/sis_course_id:<sis_course_id>/enrollments/<enrollment_id>/reactivate', 'Inscrições', null, 'canvas_inscricoes', json_template_updt_enrollment, w_msg); --'old_sis_section_id',
        r_msg := r_msg || chr(10) || w_msg;
    end view_ins_atualizar;
    
    procedure view_ins_reativar(p_sql varchar2, r_msg out clob) as
        w_msg clob;
    begin
        controller_update_request(p_sql, 'courses/sis_course_id:<sis_course_id>/enrollments/<enrollment_id>/reactivate', 'Inscrições', null, 'canvas_inscricoes', json_template_updt_enrollment, w_msg); --'old_sis_section_id',
        r_msg := r_msg || chr(10) || w_msg;
    end view_ins_reativar;
    
    /** deletar inscrições */
    procedure view_ins_deletar(p_sql varchar2, r_msg out clob) as
        w_msg clob;
    begin
        controller_delete_request(p_sql, 'courses/sis_course_id:<sis_course_id>/enrollments/<enrollment_id>?action=<action>', 'Inscrições', 'enrollment', 'canvas_inscricoes', json_template_del_enrollment, w_msg);
        r_msg := r_msg || chr(10) || w_msg;
    end view_ins_deletar;
    
    procedure view_ins_detalhes(p_sql varchar2, r_msg out clob) as
        w_msg clob;
        
        w_resposta pljson_list;
    begin
    ---p_method in varchar2, p_ds_entity in varchar2, p_entity in varchar2, p_nm_table in varchar2, p_template in varchar2, r_msg out clob
        w_resposta := controller_find(p_sql, 'enrollments/<enrollment_id>?account_id=<account_id>', 'Inscrições', 'canvas_inscricoes', json_tmpt_detail_enrollment, w_msg);
        r_msg := r_msg || chr(10) || w_msg || chr(10) || w_resposta.to_char;
    end view_ins_detalhes;
    
    procedure view_ins_update_table(p_sql varchar2, r_msg out clob) is
        w_msg clob;
        w_resposta pljson_list;
    begin
    --users/sis_user_id:<sis_user_id>/enrollments?role=<role>&state=<state>
        --controller_update_canvas_inscricoes();
        --users/sis_user_id:<sis_user_id>/enrollments?
        --users/sis_user_id:11816725978/enrollments?page=1&state%5B%5D=active&state%5B%5D=inactive
        controller_update_table(p_sql, 'users/sis_user_id:<sis_user_id>/enrollments?page=<page>&per_page=50&state%5B%5D=active&state%5B%5D=inactive&state%5B%5D=invited&state%5B%5D=deleted&state%5B%5D=creation_pending&state%5B%5D=rejected&state%5B%5D=complet', 'Inscrições', null, 'canvas_inscricoes', json_temp_updt_table_enroll, w_msg);
        r_msg := r_msg || chr(10) || w_msg;
        --util.plob(r_msg);
        insert into canvas_log
                       (nm_table
                       ,ds_log
                       ,nm_metodo)
                 values('CANVAS_INSCRICOES'
                       ,r_msg
                       ,'UPDATE TABLE CANVAS_INSCRICOES (CONTROLLER_UPDATE_TABLE)');
        --util_insert_log(r_msg, 'CANVAS_INSCRICOES', 'UPDATE TABLE CANVAS_INSCRICOES (CONTROLLER_UPDATE_TABLE)');
    end;
    
/**
    <p>
        Controle de notas, para realizar a inserção ou atualização das notas.
    </p>
    @param  r_msg           <b>retorna</b> o log.
    
*/
    procedure controller_save_notas(p_sis_section_id varchar2, r_msg out clob) is
        
        w_msg        clob;
        w_resposta   clob;
        w_json       pljson;
        w_json_list  pljson_list;
        w_nota       canvas_notas%rowtype;
        w_page       binary_integer;
        
        cursor c_nota_existe(p_canvas_id varchar2, p_sis_user_id varchar2, p_sis_section_id varchar2, p_sis_course_id varchar2) is
            select *
              from canvas_notas
             where sis_user_id    = p_sis_user_id
               and sis_section_id = p_sis_section_id
               and sis_course_id  = p_sis_course_id
               and canvas_id      = p_canvas_id;
        
        
        procedure conf_json is
            w_json_value pljson_value;
        begin
            w_json_value := w_json.get('id');
            
            w_json.remove('id');
            w_json.remove('section_id');
            w_json.remove('course_id');
            w_json.remove('user_id');
            
            w_json.put('canvas_id', w_json_value);
            w_json.put('dt_incl', 'sysdate');
        end;
        
        procedure call is
        begin
            conf_json;
            open c_nota_existe(w_json.get('canvas_id').str, w_json.get('sis_user_id').str, w_json.get('sis_section_id').str, w_json.get('sis_course_id').str);
            fetch c_nota_existe into w_nota;
            if c_nota_existe%found then
                declare
                    v_current_score number;
                    v_final_score number;
                begin
                    
                    v_current_score := to_number(coalesce(w_json.get('current_score').str, '-1'), '99999999.99');
                    v_final_score := to_number(coalesce(w_json.get('final_score').str, '-1'), '99999999.99');
                    r_msg := r_msg || chr(10) || 'Nota existe:' || w_json.to_char;
                    if w_nota.current_score != case when v_current_score = -1 then w_nota.current_score else v_current_score end
                    or w_nota.final_score !=  case when v_final_score = -1 then w_nota.final_score else v_final_score end then
                        service_update_table_notas(w_json, w_msg);
                        r_msg := r_msg || chr(10) || w_msg;
                    else
                        r_msg := r_msg || chr(10) || 'Score não foi alterado';
                        r_msg := r_msg || chr(10) || 'Canvas_id: '||w_nota.canvas_id;
                        r_msg := r_msg || chr(10) || 'Current_socore: '||TO_CHAR(w_nota.current_score)||' = '||w_json.get('current_score').str;
                        r_msg := r_msg || chr(10) || 'Final_score: '||TO_CHAR(w_nota.final_score)||' = '||w_json.get('final_score').str;
                    end if;
                end;
            else
                service_insert_table_notas(w_json, w_msg);
                r_msg := r_msg || chr(10) || w_msg;
            end if;
            close c_nota_existe;
        end;
        
        PROCEDURE call_service is
            
        begin
            r_msg := r_msg || chr(10) || 'Página:' || to_char(w_page);
            w_resposta := service_find_by('sections/sis_section_id:'||p_sis_section_id||'/enrollments?page='||to_char(w_page), w_msg);
            r_msg := r_msg || chr(10) || w_msg;
            if w_resposta is not null then
                if substr(w_resposta,1,1) = '[' then
                    w_json_list := pljson_list(util_all_atribute_to_lower(w_resposta));
                else
                    w_json := pljson(util_all_atribute_to_lower(w_resposta));
                end if;
                
                if w_json_list is not null then
                    r_msg := r_msg || chr(10) || 'Rotina em lote.';
                    r_msg := r_msg || chr(10) || 'Quantidade: '||w_json_list.count;
                    for i in 1..w_json_list.count loop
                        begin
                            r_msg := r_msg || chr(10) || '-------------------------------------------------------------';
                            w_json := pljson(w_json_list.get(i));
                            call;
                        exception
                            when others then
                                if c_nota_existe%ISOPEN then
                                    close c_nota_existe;
                                end if;
                                r_msg := r_msg || chr(10) || w_msg;
                                r_msg := r_msg || chr(10) || 'Inicio erro (controller_save_nota)';
                                r_msg := r_msg || chr(10) || util.get_erro;
                                r_msg := r_msg || chr(10) || 'Fim erro (controller_save_nota)';
                        end;
                    end loop;
                elsif w_json is not null then
                    r_msg := r_msg || chr(10) || 'Rotina individual.';
                    call;
                end if;
            end if;
        end;
    begin
        --sections/sis_section_id:DIRT3041.DIRT85K.20181/enrollments
        r_msg := 'Iniciar controller_save_notas.';
        r_msg := r_msg || chr(10) || 'Buscar inscrições por seção';
        w_page := 1;
        r_msg := r_msg || chr(10) || 'Página:' || to_char(w_page);
        w_resposta := service_find_by('sections/sis_section_id:'||p_sis_section_id||'/enrollments?page='||to_char(w_page), w_msg);
--        w_resposta := service_find_by('sections/sis_course_id:'||p_sis_section_id||'/enrollments', w_msg);

        r_msg := r_msg || chr(10) || w_msg;
        r_msg := r_msg || chr(10) || 'w_resposta:' || w_resposta;
--        util.p('w_page:'||w_page);
--        util.p(w_resposta);
        while w_resposta is not null and w_resposta != '[]' and lower(w_resposta) not like '%errors%' loop
            if substr(w_resposta,1,1) = '[' then
                w_json_list := pljson_list(util_all_atribute_to_lower(w_resposta));
            else
                w_json := pljson(util_all_atribute_to_lower(w_resposta));
            end if;
            
            if w_json_list is not null then
                r_msg := r_msg || chr(10) || 'Rotina em lote.';
                r_msg := r_msg || chr(10) || 'Quantidade: '||to_char(w_json_list.count);
                for i in 1..w_json_list.count loop
                    begin
                        r_msg := r_msg || chr(10) || '-------------------------------------------------------------';
                        w_json := pljson(w_json_list.get(i));
                        call;
                    exception
                        when others then
                            if c_nota_existe%ISOPEN then
                                close c_nota_existe;
                            end if;
                            r_msg := r_msg || chr(10) || w_msg;
                            r_msg := r_msg || chr(10) || 'Inicio erro (controller_save_nota)';
                            r_msg := r_msg || chr(10) || util.get_erro;
                            r_msg := r_msg || chr(10) || 'Fim erro (controller_save_nota)';
                    end;
                end loop;
            elsif w_json is not null then
                r_msg := r_msg || chr(10) || 'Rotina individual.';
                call;
            end if;
            w_page := w_page + 1;
            r_msg := r_msg || chr(10) || 'Buscar inscrições por seção';
            r_msg := r_msg || chr(10) || 'Página:' || to_char(w_page);
            w_resposta := service_find_by('sections/sis_section_id:'||p_sis_section_id||'/enrollments?page='||to_char(w_page), w_msg);
            r_msg := r_msg || chr(10) || 'w_resposta:' || w_resposta;
--            if w_page > 10 then
--                exit;
--            end if;
        end loop;
        exception
            when others then
                if c_nota_existe%ISOPEN then
                    close c_nota_existe;
                end if;
                r_msg := r_msg || chr(10) || w_msg;
                r_msg := r_msg || chr(10) || 'Inicio erro (controller_save_nota)';
                r_msg := r_msg || chr(10) || util.get_erro;
                r_msg := r_msg || chr(10) || 'Fim erro (controller_save_nota)';
    end;
    
    procedure view_ins_salvar_nota(p_sis_section_id varchar2, r_msg out clob, save_log boolean default true) is
        w_msg clob;
    begin
        controller_save_notas(replace(p_sis_section_id,'@','%40'), w_msg);
        r_msg := r_msg || chr(10) || w_msg;
        if save_log then
            util_insert_log(r_msg, 'CANVAS_NOTAS', 'SALVAR/ATUALIZAR '||p_sis_section_id);
        end if;
    end;
    
    procedure controller_ins_reenvio(p_sis_section_id in varchar2, p_group_id number, show_table boolean default false) is
        qt_updt number;
        v_msg clob;
    begin
        update canvas_secoes set group_id = p_group_id where sis_section_id = p_sis_section_id;
        qt_updt := sql%rowcount; 
        
        if qt_updt > 0 then
            v_msg := 'comando: update canvas_secoes set group_id = '||p_group_id||' where sis_section_id = '''||p_sis_section_id||''';';
            v_msg := chr(10) || 'Atualizado '||qt_updt||' registros';
            --util.plob(v_msg);
            v_msg := chr(10) || util.get_table_on_console('select * from canvas_secoes where sis_section_id = '''||p_sis_section_id||'''', 'canvas_secoes');
            util_insert_log(v_msg, 'CANVAS_SECOES', 'CANVAS.VIEW_INS_REENVIO');
            if show_table then
                util.show_table_on_console('select * from canvas_secoes where sis_section_id = '''||p_sis_section_id||'''', 'canvas_secoes');
            end if;
        end if;
        
        update canvas_inscricoes set dt_incl = null, canvas_id = null where sis_section_id = p_sis_section_id;
        qt_updt := sql%rowcount; 
        if qt_updt > 0 then
            v_msg := 'comando: update canvas_inscricoes set dt_incl = null where sis_section_id = '''||p_sis_section_id||''';';
            v_msg := CHR(10) || 'Atualizado '||qt_updt||' registros';  
            --util.plob(v_msg);
            v_msg := CHR(10) || util.get_table_on_console('select * from canvas_inscricoes where sis_section_id = '''||p_sis_section_id||'''', 'canvas_inscricoes');
            util_insert_log(v_msg, 'CANVAS_INSCRICOES', 'CANVAS.VIEW_INS_REENVIO');
            if show_table then
                util.show_table_on_console('select * from canvas_inscricoes where sis_section_id = '''||p_sis_section_id||'''', 'canvas_inscricoes');
            end if;
        end if;
        commit;
    end;
    
    procedure view_ins_reenvio(p_sis_section_id in varchar2, p_group_id number, show_table boolean default false) is
    begin
        controller_ins_reenvio(p_sis_section_id, p_group_id, show_table);
    end;
  
    function view_ins_user_exists(p_sis_user_id varchar2) return binary_integer is
        cursor c_inscricoes(p_sis_user_id varchar2) is
            select 1
              from CANVAS_INSCRICOES
             where sis_user_id = p_sis_user_id
               and canvas_id is not null;
         
        dummy binary_integer;
    begin
        open c_inscricoes(p_sis_user_id);
        fetch c_inscricoes into dummy;
        if c_inscricoes%found then
            return 1;
        end if;
        close c_inscricoes;
        return 0;
        exception
            when others then
                return 0;
    end;
    
    /**************************Termino Inscrições******************************/
    
    /**************************Inicio Grupos******************************/
    function view_grp_by_curso(p_sis_course_id varchar2, exibir_json boolean default false) return clob is
        w_msg clob;
    begin
--        return coalesce(service_find_by('courses/sis_course_id:'||util_convert_ascii_to_hex(p_sis_course_id)||'/group_categories', exibir_json), 'null');
        return coalesce(service_find_by('courses/'||util_convert_ascii_to_hex(p_sis_course_id)||'/assignment_groups', w_msg, exibir_json), 'null');
    end;

    function view_grp_by_subconta(p_account_id varchar2, exibir_json boolean default false) return clob is
        w_msg clob;
    begin
        return coalesce(service_find_by('accounts/'||util_convert_ascii_to_hex(p_account_id)||'/group_categories', w_msg, exibir_json), 'null');
    end;
    
    function view_grp_by_category(p_account_id varchar2, exibir_json boolean default false) return clob is
        w_msg clob;
    begin
        return coalesce(service_find_by('group_categories/group_category_id:"GRUPO SECAO"/groups', w_msg, exibir_json), 'null');
    end;
    /**************************Termino Grupos******************************/
    
    /**************************Inicio Execução************************************/
    
    
    
    
    procedure executar_script is
        pID_CURSO NUMBER;
        pID_TURMA VARCHAR2 (10);
        pNR_ANO_SEMESTRE VARCHAR2 (10);
    BEGIN

        /*INSERE E ATUALIZA USUÁRIO*/
        SCRIPT_CRIAR_USUARIO(pID_CURSO,pID_TURMA, pNR_ANO_SEMESTRE);
        SCRIPT_ATUALIZAR_USUARIO;

        /*INSERE E ATUALIZA PERIODO ACADEMICO*/
        SCRIPT_CRIAR_PERIODO_ACADEMICO(pID_CURSO,pID_TURMA, pNR_ANO_SEMESTRE);
        SCRIPT_ATUALIZAR_PERIODO_ACA;  

        /*INSERE E ATUALIZA CURSO*/
        SCRIPT_CRIAR_CURSO(pID_CURSO,pID_TURMA, pNR_ANO_SEMESTRE);
        SCRIPT_ATUALIZAR_CURSO;
        script_excluir_curso;

        /*INSERE E ATUALIZA SEÇÃO*/
        SCRIPT_CRIAR_SECAO(pID_CURSO,pID_TURMA, pNR_ANO_SEMESTRE);
        SCRIPT_ATUALIZAR_SECAO;

        /*INSERE E ATUALIZA INSCRIÇÃO*/
        SCRIPT_CRIAR_INSCRICAO(pID_CURSO,pID_TURMA, pNR_ANO_SEMESTRE);

        /*INATIVA INSCRIÇÃO*/
        SCRIPT_INATIVAR_INSCRICAO;

        /*REATIVA INSCRIÇÃO*/
        SCRIPT_REATIVAR_INSCRICAO;
    end executar_script;
    
    procedure executar_periodo_academico is
        w_msg clob;
    begin
        view_aca_salvar(
'select name
       ,sis_term_id
       ,to_char(start_at, ''rrrr-mm-dd HH24:MM:ss'') start_at
       ,to_char(end_at, ''rrrr-mm-dd HH24:MM:ss'') end_at
   from canvas_periodos_academico c
  where dt_incl is null
    and c.canvas_id is null'
        ,w_msg);
        util_insert_log(w_msg, 'CANVAS_PERIODOS_ACADEMICO', 'CRIAR');
        commit;
        w_msg := '';
        
        view_aca_atualizar(
'select name
       ,sis_term_id old_sis_term_id
       ,sis_term_id sis_term_id
       ,to_char(start_at, ''rrrr-mm-dd HH24:MM:ss'') start_at
       ,to_char(end_at, ''rrrr-mm-dd HH24:MM:ss'') end_at
   from canvas_periodos_academico c
  where dt_updt   is null
    and c.canvas_id is not null'
        ,w_msg);
        util_insert_log(w_msg, 'CANVAS_PERIODOS_ACADEMICO', 'ATUALIZAR');
        commit;
    end executar_periodo_academico;
    
    procedure executar_curso_updt_table is
        w_msg clob;
        w_sql varchar2(1000);
    begin
        w_sql := 
    'select cc.sis_course_id
      from canvas_cursos cc
     where dt_incl is null
       and cc.sis_course_id = ''POD0102B01.20183''';
      view_crs_update_table(w_sql, w_msg);
    end;

    procedure executar_curso is
        w_msg clob;
        w_sql varchar2(2000);
    begin
--        util.p('executar_curso');
        --Inserir
        w_sql := 
'select cc.account_id
       ,cc.name
       ,cc.code
       ,to_char(cc.end_at, ''rrrr-mm-dd HH24:MM:ss'') end_at
       ,to_char(cc.start_at, ''rrrr-mm-dd HH24:MM:ss'') start_at
       ,cc.restrict_to_dates
       ,cc.sis_master_id
       ,cc.sis_term_id
       ,cc.sis_course_id
       ,cc.publish
       ,cc.import_content
  from canvas_cursos cc
      ,canvas_periodos_academico cp
 where cc.sis_term_id = cp.sis_term_id
   and cc.dt_incl is null
   and cc.canvas_id is null
   and cp.canvas_id is not null';
--        util.p(w_sql);
--          where code like ''%TESTE%''
--            and rownum <= 1';--and code like ''%TESTE%''
        view_crs_salvar(w_sql,w_msg);
        util_insert_log(w_msg, 'CANVAS_CURSOS', 'CRIAR');
        commit;
        
        
        
        --Atualizar
        w_msg := '';
        w_sql := 
'select ACCOUNT_ID
       ,NAME
       ,CODE
       ,to_char(end_at, ''rrrr-mm-dd HH24:MM:ss'') end_at
       ,to_char(start_at, ''rrrr-mm-dd HH24:MM:ss'') start_at
       ,RESTRICT_TO_DATES
       ,SIS_TERM_ID
       ,SIS_COURSE_ID
       ,SIS_COURSE_ID OLD_SIS_COURSE_ID
       ,EVENT
   from canvas_cursos c
  where dt_updt   is null
    and c.canvas_id is not null';
        view_crs_atualizar(w_sql,w_msg);
        util_insert_log(w_msg, 'CANVAS_CURSOS', 'ATUALIZAR'); 
        commit;
        
        --Liberar e eliminar
        w_sql := 
'select REPLACE(cce.SIS_COURSE_ID, ''@'', ''%40'') SIS_COURSE_ID
   from CANVAS_CURSOS_EXCL cce
       ,CANVAS_SECOES_EXCL cse
  where cce.SIS_COURSE_ID = cse.SIS_COURSE_ID 
    and cse.DT_EXCL is not null
    and cce.dt_updt is null';
        view_crs_liberar_eliminar(w_sql,w_msg);
        util_insert_log(w_msg, 'CANVAS_CURSOS_EXCL', 'LIBERAR_ELIMINAR'); 
        commit;
    end executar_curso;
    
    procedure executar_usuario is
        w_msg clob;
        w_sql varchar2(2000);
    begin
        
        w_sql := 
'select full_name
       ,short_name
       ,sortable_name
       ,auth_provider_id
       ,email
       ,login
       ,password
       ,sis_user_id
   from canvas_usuarios c
  where dt_incl     is null
    and c.canvas_id is null';
        view_usr_salvar(w_sql,w_msg, p_verify_id => false);
        util_insert_log(w_msg, 'CANVAS_USUARIOS', 'CRIAR');
        commit;
        
        w_msg := '';
        w_sql := 
'select canvas_id user_id
       ,full_name
       ,short_name
       ,sortable_name
       ,email
       ,login
       ,password
       ,sis_user_id
   from canvas_usuarios
  where dt_updt   is null
    and canvas_id is not null';
          --where upper(full_name) like ''%TESTE%'''; 
        view_usr_atualizar(w_sql,w_msg);
        util_insert_log(w_msg, 'CANVAS_USUARIOS', 'ATUALIZAR');
        commit;
    end executar_usuario;
    
    procedure executar_secao is
        w_msg clob;
        w_sql varchar2(2000);
    begin
        --Inserir
        w_sql := 
'select cs.sis_course_id 
       ,cs.name
       ,to_char(cs.end_at, ''rrrr-mm-dd HH24:MM:ss'') end_at
       ,to_char(cs.start_at, ''rrrr-mm-dd HH24:MM:ss'') start_at
       ,cs.sis_section_id sis_section_id
       ,cs.isolate_section
       ,cs.restrict_to_dates
   from canvas_secoes cs
       ,canvas_cursos cc
  where cs.dt_incl is null
    and cc.sis_course_id = cs.sis_course_id
    and cs.canvas_id is null
    and cc.canvas_id is not null'; --and sis_course_id like ''SER@1018.20171''
        view_scs_salvar(w_sql,w_msg, p_verify_id => false);
        util_insert_log(w_msg, 'CANVAS_SECOES', 'CRIAR');
        commit;

        --Atualizar
        w_msg := '';
        w_sql :=
'select cs.sis_section_id old_sis_section_id
       ,cs.sis_section_id
       ,cs.name
       ,to_char(end_at, ''rrrr-mm-dd HH24:MI:ss'') end_at
       ,to_char(start_at, ''rrrr-mm-dd HH24:MI:ss'') start_at
       ,cs.restrict_to_dates
   from canvas_secoes cs
  where cs.dt_updt is null
    and cs.canvas_id is not null';
        view_scs_atualizar(w_sql,w_msg);
        util_insert_log(w_msg, 'CANVAS_SECOES', 'ATUALIZAR');
        commit;
        
        --Liberar e eliminar
        w_msg := '';
        w_sql := 
'select REPLACE(c.SIS_SECTION_ID, ''@'', ''%40'') SIS_SECTION_ID
   from CANVAS_SECOES_EXCL c
       ,canvas_cursos cc
  where c.dt_excl is null
    and cc.sis_course_id = c.sis_course_id
    and cc.canvas_id is not null';
        view_scs_liberar_eliminar(w_sql,w_msg);
        util_insert_log(w_msg, 'CANVAS_SECOES_EXCL', 'LIBERAR_ELIMINAR'); 
        commit;
    end executar_secao; 
    
    procedure executar_inscricao_updt_table is
        w_msg clob;
        w_sql varchar2(1000);
    begin
        w_sql := 
'select distinct ci.sis_user_id
  from canvas_inscricoes ci
 WHERE EXISTS(SELECT CANVAS_ID
                FROM CANVAS_INSCRICOES CI2
               WHERE CI2.CANVAS_ID = CI.CANVAS_ID
               GROUP BY CANVAS_ID
              HAVING COUNT(CANVAS_ID) > 1)';
 /*'select distinct ci.sis_user_id
    from canvas_inscricoes ci
   where dt_incl   is not null
     and dt_updt   is null
     and canvas_id is not null
     and action    is null
     and rownum <= 2500';*/
     
    /*'select distinct ci.sis_user_id
      from canvas_inscricoes ci
     where ci.sis_user_id = ''05803264970''
       and rownum <= 1';--ci.dt_updt is null*/
      view_ins_update_table(w_sql, w_msg);
    end;
    
    procedure executar_inscricao is
        w_msg clob;
        w_sql varchar2(2000);
    begin
--        --INSERT   
        w_sql := 
'select distinct ''sis_user_id:''||cu.sis_user_id user_id
       ,ci.sis_user_id
       ,ci.type
       ,ci.role_id
       ,REPLACE(ci.sis_section_id, ''@'', ''%40'') sis_section_id 
       ,ci.state
       ,ci.limit_interaction
       ,ci.send_notification
       ,ci.canvas_id enrollment_id
       ,cs.group_id
  from canvas_inscricoes ci
      ,canvas_usuarios cu
      ,canvas_secoes cs
  where ci.dt_incl        is null
    and ci.canvas_id      is null
    and ci.sis_user_id    = cu.login
    and cu.canvas_id      is not null
    and ci.sis_section_id = cs.sis_section_id
    and cs.group_id       is not null
    and rownum <= 1000';
    --and type = case when (select count(distinct type) from canvas_inscricoes where sis_user_id = cu.sis_user_id and sis_section_id = cs.sis_section_id and state = ''active'') > 1 then ''TeacherEnrollment'' else type end
        view_ins_salvar(w_sql,w_msg);
        util_insert_log(w_msg, 'CANVAS_INSCRICOES', 'CRIAR');
        commit;

--        --REATIVAR INSCRIÇÃO
      /*  w_msg := '';
        w_sql := 
'select REPLACE(cs.sis_course_id, ''@'', ''%40'') sis_course_id
       ,ci.canvas_id enrollment_id
       ,ci.canvas_id
       ,ci.role_id
       ,ci.sis_user_id
       ,ci.sis_section_id
   from canvas_inscricoes ci
       ,canvas_secoes cs
       ,canvas_usuarios cu
  where ci.sis_section_id = cs.sis_section_id
    and lower(ci.action)  in (''reactivate'')
    and ci.dt_updt        is null
    and cu.login         = ci.sis_user_id
    and cu.canvas_id is not null
    and rownum <= 1000';
        view_ins_reativar(w_sql,w_msg);
        util_insert_log(w_msg, 'CANVAS_INSCRICOES', 'REATIVAR_INSCRICOES');
        commit;

        --DELETAR/DESATIVAR/CONCLUIR
        w_msg := '';
        w_sql := 
'select REPLACE(cs.sis_course_id, ''@'', ''%40'') sis_course_id
       ,ci.canvas_id enrollment_id
       ,ci.canvas_id
       ,ci.role_id
       ,ci.action
       ,ci.sis_user_id
       ,ci.sis_section_id
   from canvas_inscricoes ci
       ,canvas_secoes cs
  where ci.sis_section_id = cs.sis_section_id
    and ci.dt_updt is null
    and ci.state != ci.action
    and ci.canvas_id is not null
    and ci.action in (''conclude'', ''delete'', ''deactivate'')
    and rownum <= 1000';*/
    
        view_ins_deletar(w_sql,w_msg);
        util_insert_log(w_msg, 'CANVAS_INSCRICOES', 'DELETAR');
        commit;
    end executar_inscricao;
    
    procedure executar_notas is
        cursor c_secoes is
           SELECT DISTINCT SECAO.SIS_SECTION_ID--SECAO.*
              FROM canvas_secoes secao 
                  ,CAC_TURMAS        CTUR 
                  ,CAC_CURSOS        CCUR
                  ,CANVAS_LOG CLOG
             WHERE CTUR.NR_ANO_SEMESTRE = SUBSTR(secao.SIS_SECTION_ID,-5) 
               AND CTUR.ID_TURMA        = SUBSTR(secao.SIS_SECTION_ID,INSTR(secao.SIS_SECTION_ID,'.') + 1, (INSTR(secao.SIS_SECTION_ID,'.', INSTR(secao.SIS_SECTION_ID,'.') + 1) - (INSTR(secao.SIS_SECTION_ID,'.') + 1)))
               AND CTUR.ID_CURSO        = CCUR.ID_CURSO 
    --           and secao.SIS_SECTION_ID like '%ADM0101B01%'
               AND ORIGEM_DOMINIO('CAC_CURSOS','ST_ESPECIALIZACAO',ccur.ST_ESPECIALIZACAO) = 'GRAD-EAD' 
               AND SECAO.CANVAS_ID is not null
               AND SECAO.DT_INCL   is not null
               AND CLOG.NM_METODO NOT LIKE '%'||SECAO.SIS_SECTION_ID||'%'
               AND CLOG.DT_INCL > DATE '2018-06-26'
               AND SECAO.SIS_SECTION_ID NOT IN ('ADM0101B01.ADM@401K.20181', 'SER0101B01.SER@401K.20181')
               AND CCUR.ID_CURSO   not in (80)
             ORDER BY SECAO.SIS_SECTION_ID;
          
        secao canvas_secoes.sis_section_id%type;
        w_msg clob;
    begin

        open c_secoes;
        fetch c_secoes into secao;
    
        while c_secoes%found loop
            view_ins_salvar_nota(secao, w_msg);
            --util.plob(w_msg);
            fetch c_secoes into secao;
        end loop;
        
        close c_secoes;
    end;
    
/**
    Vincular todas as inscrições com perfil diferente de 
    "StudentEnrollment".
    Obs: esta rotina já esta fazendo, logo após enviar uma inscrição
    "executar_inscricao".
*/
    procedure executar_vincular_grupo is
        w_msg clob;
        w_sql varchar2(1000);
        
    begin
        w_sql := 
'select distinct ''sis_user_id:''||cu.sis_user_id user_id
       ,ci.sis_user_id
       ,ci.type
       ,ci.role_id
       ,REPLACE(ci.sis_section_id, ''@'', ''%40'') sis_section_id 
       ,ci.state
       ,ci.limit_interaction
       ,ci.send_notification
       ,ci.canvas_id enrollment_id
       ,cs.group_id
  from canvas_inscricoes ci
      ,canvas_usuarios cu
      ,canvas_secoes cs
  where ci.sis_user_id    = cu.sis_user_id
    and ci.sis_section_id = cs.sis_section_id
    and cu.canvas_id      is not null
    and cs.group_id       is not null
    and cs.canvas_id      is not null
    and ci.canvas_id      is not null
    and ci.type != ''StudentEnrollment''';
        view_ins_salvar(w_sql, w_msg);
        util_insert_log(w_msg, 'CANVAS_INSCRICOES', 'VINCULAR GRUPO');

    end;
    
        
    procedure EXECUTAR_INTEGRACAO is
    begin
        executar_script;
        executar_periodo_academico;
        executar_curso;
        executar_usuario;
        executar_secao;
        executar_inscricao;
        alerta_curso;
    end;
    /**************************Termino Execução***********************************/
        
    procedure stop_job is
    begin
        util.job_stop('JOB_CANVAS');
    end;
    
    procedure enabled_job is
    begin
        util.job_enable('JOB_CANVAS');
    end;
    
    procedure disable_job is
    begin
        util.job_disable('JOB_CANVAS');
    end;

    procedure running_job is 
    begin
        util.job_run('JOB_CANVAS');
    end;
    
--    procedure jobs_is_running is
--        cursor c_jobs(p_job_name in varchar2) is
--            select job_name, 
--                   session_id 
--              from dba_scheduler_running_jobs
--             where job_name = p_job_name;
--    begin
--        if util.job_is_runnig('JOB_CANVAS') then
--            util.p('JOB_CANVAS is running');
--        else
--            util.p('JOB_CANVAS is not running');
--        end if;
--    end;

    procedure alerta_curso is
        cursor c_cursos is
            select name nm_curso
                  ,sis_master_id
                  ,sis_term_id
                  ,sis_course_id
              from canvas_cursos
             where canvas_id is NULL
               and dt_incl is null
             union all
            select cs.name nm_curso
                  ,cc.sis_master_id
                  ,cc.sis_term_id
                  ,cs.sis_course_id
              from canvas_secoes cs
                  ,canvas_cursos cc
             where cs.canvas_id is NULL
               and cs.dt_incl is null
               and cs.sis_course_id = cc.sis_course_id;
        
        w_curso c_cursos%rowtype;
        
        ds_cursos clob;
    begin
        ds_cursos := util.get_table_on_console(
'select name
       ,sis_master_id
       ,sis_term_id
       ,sis_course_id
   from canvas_cursos
  where canvas_id is NULL
    and dt_incl is null
  union all
 select cs.name
       ,cc.sis_master_id
       ,cc.sis_term_id
       ,cs.sis_course_id
   from canvas_secoes cs
       ,canvas_cursos cc
  where cs.canvas_id is NULL
    and cs.dt_incl is null
    and cs.sis_course_id = cc.sis_course_id','CANVAS_CURSOS', false, true);
--            util.plob(ds_cursos);
        if ds_cursos is not null then
            ds_cursos := '<h1>Integração CANVAS - requisição de cursos</h1><br/><p align="center"><div align="center"><h2>Segue abaixo os curso(s) que não foram inseridos, por favor verificar no <em><b>CANVAS</b></em>, o "GRUPO SECAO" e/ou "ID do SIS".</h2></p></div><br/><br/><p><h4>CANVAS_CURSOS:<h4></p><br/>' || ds_cursos;
            util.send_email(p_para => 'bruno.jorge@unifil.br', p_cc => 'sistemas@unifil.br; renan.falleiros@unifil.br', p_assunto => 'Canvas (Integração) - Erro ao tentar enviar o(s) curso(s)', p_mensagem => ds_cursos);
        end if; 
    
    end;
    
    procedure alerta_secao is
        cursor c_secoes is
            select *
              from canvas_secoes
             where canvas_id is NULL
               and dt_incl is null;
        
        w_curso c_secoes%rowtype;
        
        ds_secoes clob;
    begin
        ds_secoes := util.get_table_on_console(
'select *
   from canvas_secoes
  where canvas_id is NULL
    and dt_incl is null','CANVAS_SECOES', false);
--        util.plob(ds_cursos);
        if ds_secoes is not null then
            ds_secoes := '<h1>Integração CANVAS - requisição de seções</h1><br/><p align="center"><div align="center"><h2>Segue abaixo as secçõe(s) que não foram inseridos, por favor verificar no <em><b>CANVAS</b></em>.</h2></p></div><br/><br/><p><h4>CANVAS_SECOES:<h4></p><br/>' || ds_secoes;
--            util.send_email(p_para => '', p_cc => 'dmorita@unifil.br', p_assunto => 'Canvas (Integração) - Erro ao tentar enviar o(s) curso(s)', p_mensagem => ds_cursos);
        end if;
    
    end;
    
end canvas;