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


<%-- Under construction. Display info in plain text to those without edit permission --%>

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
    select title, summary, state, created crdate, keyprj, active, lastmodified moddate from descpub_project where id = ?  
    <sql:param value="${projid}"/>
</sql:query>

<c:set var="keyproj" value="${projects.rows[0].keyprj}"/>
<c:set var="title" value="${projects.rows[0].title}"/>
<c:set var="projstate" value="${projects.rows[0].state}"/>
<c:set var="summary" value="${projects.rows[0].summary}"/>

<h2>Project: [${projid}] ${projects.rows[0].title}  </h2>
<h3>Created: ${projects.rows[0].crdate} &nbsp;&nbsp; Last Modified: ${projects.rows[0].moddate}</h3>
    
    