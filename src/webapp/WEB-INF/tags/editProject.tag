<%@tag pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib prefix="gm" uri="http://srs.slac.stanford.edu/GroupManager"%>

<%@attribute name="projid" required="true"%>
<%@attribute name="swgid" required="true"%>
<%@attribute name="experiment" required="true" %>
<%@attribute name="returnURL" required="true" %>
    
<%--
    <c:if test="${!(gm:isUserInGroup(pageContext,'descpubConvenerAdmin'))}">
        <c:redirect url="noPermission.jsp?errmsg=1"/>
    </c:if> --%>

    <c:set var="tmp" value="created,active,inactive,completed"/>
    <c:set var="validStates" value="${fn:split(tmp,',')}"/>  
    
    <%-- project can have multiple working groups assigned so execute separate query to get all working groups --%> 
    <sql:query var="swgcurr" dataSource="jdbc/config-dev">
         select wg.name, wg.id from descpub_swg wg join descpub_project_swgs ps on wg.id = ps.swg_id where ps.project_id = ? order by wg.name
        <sql:param value="${projid}"/>
    </sql:query>  
     
          
         
    <sql:query var="swgcandidates" dataSource="jdbc/config-dev">
        select name, id from descpub_swg where name not in 
        (select wg.name from descpub_swg wg join descpub_project_swgs ps on wg.id = ps.swg_id where ps.project_id = ?) 
        order by name
        <sql:param value="${projid}"/>
    </sql:query>
    
    <sql:query var="projects" dataSource="jdbc/config-dev">
        select wg.name swgname, wg.profile_group_name pgn, wg.convener_group_name cgn, pj.title, pj.abstract abs, pj.state, pj.created, pj.comments comm, pj.keyprj, pj.lastmodified 
        from descpub_swg wg join descpub_project_swgs ps on wg.id = ps.swg_id 
        join descpub_project pj on pj.id = ps.project_id where ps.project_id = ? and wg.id = ?
        <sql:param value="${projid}"/>
        <sql:param value="${swgid}"/>
    </sql:query>
    
        
   
    
    <c:set var="keyprj" value="${projects.rows[0].keyprj}"/>
    <c:set var="title" value="${projects.rows[0].title}"/>
    <c:set var="projstate" value="${projects.rows[0].state}"/>
    <c:set var="abs" value="${projects.rows[0].abs}"/>
    <c:set var="comm" value="${projects.rows[0].comm}"/>

    <strong>Email Project Members</strong> 
    <p/>
    
<form action="modifySWGprojects.jsp">  
    <input type="hidden" name="swgid" id="swgid" value="${swgcurr.rows[0].id}" />  
    <input type="hidden" name="projid" id="projid" value="${projid}" /> 
    <input type="hidden" name="redirectURL" id="redirectURL" value="show_project.jsp" />  
    Key Project: <input type="text" name="isKeyProj" id="isKeyProj" value="${keyprj}" size="1"/><p/>
    Title: <input type="text" name="title" id="title" value="${title}" size="55" required/><p/>
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
   
    <table border="0">
    <tr><td>Change State</td></tr>
    <tr><td>
    <select name="chgstate" id="chgstate" size="8" multiple required>
    <c:forEach var="sta" items="${validStates}" >
       <option value="${sta}" <c:if test="${fn:startsWith(sta,projstate)}">selected</c:if> >${sta}</option>
    </c:forEach>
    </select> 
    </tr></td>
    </table>
    
    Abstract:<br/> <textarea id="abs" rows="8" cols="50" name="abs">${abs}</textarea>
    <p/>
    Comments:<br/> <textarea id="comm" rows="8" cols="50" name="comm">${comm}</textarea>
    <p/>
  
    <tr>
       <td><input type="submit" value="Update_Project" id="action" name="action" /></td>     
    </tr>  
</form>

<p/>
<hr/>