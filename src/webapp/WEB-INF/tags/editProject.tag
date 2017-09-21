<%@tag pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib tagdir="/WEB-INF/tags/" prefix="tg"%>
<%@taglib prefix="gm" uri="http://srs.slac.stanford.edu/GroupManager"%>

<%@attribute name="projid" required="true"%>
<%-- <%@attribute name="swgid" required="true"%> --%>
<%@attribute name="experiment" required="true" %>
<%@attribute name="returnURL" required="true" %>
    
 
    <c:if test="${!(gm:isUserInGroup(pageContext,'lsst-desc-members'))}">
        <c:redirect url="noPermission.jsp?errmsg=1"/>
    </c:if>  
   
    <sql:query var="validStates">
        select state from descpub_project_states order by state
    </sql:query>
    
    <%-- project can have multiple working groups assigned so execute separate query to get all working groups --%> 
    <sql:query var="swgcurr">
         select wg.name, wg.id from descpub_swg wg join descpub_project_swgs ps on wg.id = ps.swg_id where ps.project_id = ? order by wg.name
        <sql:param value="${projid}"/>
    </sql:query>  
     
    <sql:query var="swgcandidates">
        select name, id from descpub_swg where name not in 
        (select wg.name from descpub_swg wg join descpub_project_swgs ps on wg.id = ps.swg_id where ps.project_id = ?) 
        order by name
        <sql:param value="${projid}"/>
    </sql:query>
   
        
    <sql:query var="projects">
        select title, abstract abs, state, created crdate, comments comm, keyprj, lastmodified moddate from descpub_project where id = ?  
        <sql:param value="${projid}"/>
    </sql:query>
        
    <c:set var="keyproj" value="${projects.rows[0].keyprj}"/>
    <c:set var="title" value="${projects.rows[0].title}"/>
    <c:set var="projstate" value="${projects.rows[0].state}"/>
    <c:set var="abs" value="${projects.rows[0].abs}"/>
    <c:set var="comm" value="${projects.rows[0].comm}"/>
   
    <h2>Project: [${projid}] ${projects.rows[0].title}  </h2>
    <h3>Created: ${projects.rows[0].crdate} &nbsp;&nbsp; Last Modified: ${projects.rows[0].moddate}</h3>
    
    <strong>Email Project Members</strong> 
    <p/>
    
<form action="modifySWGprojects.jsp">  
   <%-- <input type="hidden" name="swgid" id="swgid" value="${swgcurr.rows[0].id}" />  --%>
    <input type="hidden" name="projid" id="projid" value="${projid}" /> 
    <input type="hidden" name="redirectURL" id="redirectURL" value="show_project.jsp?projid=${projid}" />  
    
    Key Project: 
    <select name="isKeyprj" id="isKeyprj">
        <option value="Y" <c:if test="${keyproj == 'Y'}"> selected</c:if> > Y</option>
        <option value="N" <c:if test="${keyproj == 'N'}"> selected</c:if> > N</option>
    </select> 
    <p/>
   
    Title: <input type="text" name="title" id="title" value="${title}" size="55" required/><p/>
    <table border="0">
        <tr><td>Add working group</td><td>Remove working group</td></tr>
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
        <tr><td>State</td></tr>
        <tr><td>
        <select name="chgstate" id="chgstate" size="8" required>
        <c:forEach var="sta" items="${validStates.rows}" >
           <option value="${sta.state}" <c:if test="${fn:startsWith(sta.state,projstate)}">selected</c:if> >${sta.state}</option>
        </c:forEach>
        </select> 
        </tr></td>
    </table>
    <p/>
    Abstract:<br/> <textarea id="abs" rows="8" cols="50" name="abs">${abs}</textarea>
    <p/>
    Comments:<br/> <textarea id="comm" rows="8" cols="50" name="comm">${comm}</textarea>
    <p/>
  
    <tr>
       <td><input type="submit" value="Update_Project" id="action" name="action" /></td>     
    </tr>  
</form>
<p/>
<p/>
