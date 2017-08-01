<%-- 
    Document   : publications
    Created on : Jun 30, 2017, 10:30:01 AM
    Author     : chee
--%>
<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib tagdir="/WEB-INF/tags/" prefix="tg"%>
<%@taglib uri="http://srs.slac.stanford.edu/displaytag" prefix="displayutils" %>
<%@taglib prefix="gm" uri="http://srs.slac.stanford.edu/GroupManager"%>

<!DOCTYPE html>

<html>
 <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <link rel="stylesheet" href="css/site-demos.css">
    <script src="js/jquery-1.11.1.min.js"></script>
    <script src="js/jquery.validate.min.js"></script>
    <title>LSST-DESC Project Details</title>
</head>

<body>
    <c:set var="candidate_group" value="lsst-desc-full-members"/>
    
    <sql:query var="swgs" dataSource="jdbc/config-dev">
        select id, name, profile_group_name as pgn, convener_group_name as cgn from descpub_swg where id != ?
        <sql:param value="${param.swgid}"/>
    </sql:query>
        
    <sql:query var="swgproj" dataSource="jdbc/config-dev">
        select p.id, p.keyprj, p.title, p.state, wg.name from descpub_project p join descpub_project_swgs ps on p.id=ps.project_id
        join descpub_swg wg on ps.swg_id=wg.id where p.id=? order by p.id
        <sql:param value="${param.id}"/>
    </sql:query>
        
    <sql:query var="detail" dataSource="jdbc/config-dev">
        select id,title,abstract as abs,state,created,comments,keyprj from descpub_project where active='Y' and id=? 
        <sql:param value="${param.id}"/>
    </sql:query>
    
    <sql:query var="details" dataSource="jdbc/config-dev">    
        select dp.title, dp.abstract as abs, dp.state, dp.keyprj, wg.name, wg.profile_group_name as pgn from 
        descpub_project dp join descpub_project_swgs sg on dp.id = sg.project_id join descpub_swg wg on wg.id = sg.swg_id
        where dp.id = ?
        <sql:param value="${param.id}"/>
    </sql:query>
   
    <%-- for debugging --%>
    <c:forEach var="x" items="${param}">
        <c:out value="P: ${x.key}=${x.value}"/><br/>
    </c:forEach>  
   
    <%-- get sequence number here because sequence doesn't work in sql:transaction  
    <c:choose>
    <c:when test="${param.task == 'create_proj_form'}">
        <sql:query var="getNum" dataSource="jdbc/config-dev">
             select descpub_proj_seq.nextval from dual
        </sql:query>
         <sql:query var="getswgnum" dataSource="jdbc/config-dev">
             select swg_seq.nextval from dual
        </sql:query>
    </c:when>
    <c:when test="${param.formsubmitted == 'true'}">
         <sql:query var="newProjNum" dataSource="jdbc/config-dev">
             select descpub_proj_seq.currval as newProjNum from dual
        </sql:query>
        <c:set var="newProjNum" value="${newProjNum.rows[0]['newProjNum']}"/>
        <h3>newProjNum ${newProjNum}</h3>
         <sql:query var="newSwgNum" dataSource="jdbc/config-dev">
             select swg_seq.currval as newSwgNum from dual
        </sql:query>
        <c:set var="newSwgNum" value="${newSwgNum.rows[0]['newSwgNum']}"/>
        <h3>newSwgNum ${newSwgNum}</h3>
        
    </c:when>
    </c:choose>  
       --%> 
       
    <c:choose>  
        <c:when test="${param.task == 'create_proj_form'}">
             <h3>SWG: ${param.swgname}</h3><p/>
            <form name="addproject" action="project_details.jsp?task=addproject&swgid=${param.swgid}&swgname=${param.swgname}">
                <strong>Title</strong> &nbsp;&nbsp;<input type="text" name="title" required/><p/>
                <strong>Abstract<br/></strong><textarea rows="22" cols="80" name="abs" required></textarea>
                <input type="hidden" value="${param.swgid}" name="swgid"/><p/>
                <input type="hidden" value="${param.swgname}" name="swgname"/><p/>
                <input type="hidden" value="created" name="state"/><p/>
                <input type="hidden" value="true" name="formsubmitted"/><p/>
                <input type="hidden" value="N" name="keyprj"/>
                <input type="submit" value="Create" name="submit">
            </form>
        </c:when>
        <c:when test="${param.formsubmitted == 'true'}">
            <c:set var="trapError" value=""/>
            <c:catch var="trapError">
                <sql:transaction dataSource="jdbc/config-dev">
                    <sql:update >
                    insert into configdev.descpub_project (id,title,abstract,state,created,keyprj) values(DESCPUB_PROJ_SEQ.nextval,?,?,?,sysdate,?)
                    <sql:param value="${param.title}"/>
                    <sql:param value="${param.abs}"/>
                    <sql:param value="${param.state}"/>
                    <sql:param value="${param.keyprj}"/>
                    </sql:update>

                     
                    <sql:query var="projNum">
                        select configdev.descpub_proj_seq.currval as newProjNum from dual
                    </sql:query>  

                    <sql:update var="swg_proj">
                        insert into configdev.descpub_project_swgs (id,project_id,swg_id) values(SWG_SEQ.nextval,?,?)
                        <sql:param value="${projNum.rows[0]['newProjNum']}"/>
                        <sql:param value="${param.swgid}"/>
                    </sql:update>
              </sql:transaction>
            </c:catch>

            <c:if test="${!empty trapError}">
                Create project ${param.title} failed.<br/>
             <%--   <h3> insert into descpub_project (id,title,abstract,state,created,keyprj) <br/>
                values(${projNum.rows[0]['newProjNum']},${param.title},${param.abs},'created',sysdate,'N')<br/>
                <p/>
                    
                insert into descpub_project_swgs (id, project_id, swg_id)<br/>
                values(${swg_seq.currval},${projNum.rows[0]['newProjNum']}, ${param.swgid}<br/>
                
                project id =${projNum.rows[0]['newProjNum']}<br/>
                swgid = ${param.swgid}<h3/> --%>
                ${trapError}
            </c:if> 
            <c:if test="${empty trapError}">
               Created ${param.title}
            </c:if>    
        </c:when>
    </c:choose>
<p/>
<hr/>
<p/>
Project Members

<tg:groupMemberEditor experiment="${appVariables.experiment}" candidategroup="${candidate_group}" groupname="${swgs.rows[0].cgn}"/> 

<hr/>
<p/>
 
</body>
</html>
 
