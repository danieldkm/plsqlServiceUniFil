# PLSQL Service REST

Integração com Plataforma "EAD" utilizando. 
Projeto desenvolvido para consumir serviço REST, utilizando a linguagem PL/SQL.

## Instalação

1. Faça o clone deste projeto com `git clone https://github.com/danieldkm/plsqlServiceUniFil.git`.
2. Instalar o `Oracle Database`.
3. Instalar o [PLJSON](https://github.com/pljson/pljson).
4. Copie o arquivo `integracaoCanvas` para um destino padrão e altere o mesmo.
5. Use o `sql*plus` ou alguma outra ferramenta capaz de rodar scripts, para rodar o `install.sql`.
6. Gerar documentação `./build-apidocs.sh`, se estiver no windows instale o `Cygwin64`.


### Testando

```
declare
  	obj o_canvas;
  	w_msg clob;
  	respostas pljson_list;
begin
	--obj := new o_canvas_usuario;
	--respostas := obj.find_all(w_msg);
	--respostas.print;

	obj := new o_canvas_curso;
	respostas := obj.find_all(w_msg);
	--respostas.print;
    util.plob(w_msg||'oxi');
end;
/
```

## Desenvolvimento

## Construído com

* [OracleDatabase](https://docs.oracle.com/cd/E11882_01/server.112/e10897/install.htm#ADMQS002) - O `Oracle` é um `SGBD` (sistema gerenciador de banco de dados).
* [PLDoc](http://pldoc.sourceforge.net/maven-site/) - O `pldoc` é um utilitário de código aberto para gerar documentação `HTML` de código escrito em `Oracle PL/SQL`.

## Authors

* **Daniel Keyti Morita** - *Initial work* - [DKM](https://github.com/danieldkm)

## License

Este projeto está licenciado sob a MIT License - veja o [LICENSE.md](LICENSE)