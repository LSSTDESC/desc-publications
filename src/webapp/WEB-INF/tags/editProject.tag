<%@tag pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib prefix="gm" uri="http://srs.slac.stanford.edu/GroupManager"%>

<%@attribute name="projid" required="true"%>
<%@attribute name="swgid" required="true" %> 
<%@attribute name="experiment" required="true" %>

    <c:set var="tmp" value="active,created,inactive,completed"/>
    <c:set var="validStates" value="${fn:split(tmp,',')}"/>
    
    <sql:query var="swgcurr" dataSource="jdbc/config-dev">
         select wg.name, wg.id from descpub_swg wg join descpub_project_swgs ps on wg.id = ps.swg_id where ps.project_id = ? order by wg.name
        <sql:param value="${param.projid}"/>
    </sql:query>
         
    <sql:query var="swgcandidates" dataSource="jdbc/config-dev">
        select name, id from descpub_swg where name not in 
        (select wg.name from descpub_swg wg join descpub_project_swgs ps on wg.id = ps.swg_id where ps.project_id = ?) 
        order by name
        <sql:param value="${param.projid}"/>
    </sql:query>
    
    <sql:query var="projects" dataSource="jdbc/config-dev">
         select id, title, abstract abs, state, created, comments comm, keyprj, lastmodified from descpub_project where id = ?
        <sql:param value="${param.projid}"/>
    </sql:query>
         
    <sql:query var="wg" dataSource="jdbc/config-dev">
        select wg.name, wg.id, wg.profile_group_name pgn, wg.convener_group_name cgn  
        from descpub_swg wg join descpub_project_swgs ps on wg.id = ps.swg_id where ps.project_id = ? 
    <sql:param value="${param.projid}"/>
    </sql:query>
    
    <c:set var="keyprj" value="${projects.rows[0].keyprj}"/>
    <c:set var="title" value="${param.name}"/>
    <c:set var="createdate" value="${projects.rows[0].created}"/>
    <c:set var="state" value="${projects.rows[0].state}"/>
    <c:set var="swgname" value="${wg.rows[0].name}"/>
    <c:set var="swgid" value="${wg.rows[0].id}"/>
    <c:set var="cgn" value="${wg.rows[0].cgn}"/>
    <c:set var="abs" value="${projects.rows[0].abs}"/>
    <c:set var="comm" value="${projects.rows[0].comm}"/>

       
    <h2>Project: [${param.projid}] ${title}  </h2>
    <h2>WG: ${wg.rows[0].name} [${wg.rows[0].id}]</h2>
    <p/>Created: ${projects.rows[0].created}<p/>
    <strong>disable project</strong> &nbsp;&nbsp;<strong>email project members</strong>
    
<form action="modifySWGprojects.jsp">  
    <input type="hidden" name="swgid" id="swgid" value="${swgcurr.rows[0].id}" />  
    <input type="hidden" name="projid" id="projid" value="${projid}" />  
    
    Title: <input type="text" name="title" id="title" value="${title}" required/><p/>
    <table border="0">
        <tr><td>Add WG</td><td>Remove WG</td></tr>
        <tr>
            <td><select name="addprojswg" id="addprojswg" size="8" multiple>
            <c:forEach var="addrow" items="${swgcandidates.rows}">
              <option value="${addrow.id}">${addrow.name}</option>
            </c:forEach>
            </select></td>
            <td> 
            <select name="removeprojswg" id="removeprojswg" size="8" multiple>
            <c:forEach var="remrow" items="${swgcurr.rows}">
              <option value="${remrow.id}">${remrow.name}</option>
            </c:forEach>
            </select> 
            </td>
        </tr>
    </table>
    <p/>
   
    <p/>
     
    <table border="0">
    <tr><td>Change State</td></tr>
    <tr><td>
    <select name="chgstate" id="chgstate" size="8" multiple required>
    <c:forEach var="sta" items="${validStates}" >
       <option value="${sta}" <c:if test="${fn:startsWith(sta,state)}">selected</c:if> >${sta}</option>
    </c:forEach>
    </select> 
    </tr></td>
    </table>
    
    Abstract:<br/> <textarea id="abs" rows="8" cols="50" name="abs">${abs}</textarea>
    <p/>
    Comments:<br/> <textarea id="comm" rows="8" cols="50" name="comm">${comm}</textarea>
    <p/>
    Key Project:<br/><input type="checkbox" id="isKeyProj" name="isKeyProj" value="${keyprj}"/>
    <tr>
       <td><input type="submit" value="Update_Project" id="action" name="action" /></td>     
    </tr>
</form>  