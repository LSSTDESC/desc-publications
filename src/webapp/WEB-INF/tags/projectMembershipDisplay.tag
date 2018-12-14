<%@tag pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net"  prefix="display" %>
<%@taglib prefix="gm" uri="http://srs.slac.stanford.edu/GroupManager"%>
<%@taglib tagdir="/WEB-INF/tags" prefix="g"%>


<%@attribute name="groupname" required="true"%>
<%@attribute name="returnURL" required="true" %>

<sql:query var="members">
    select u.first_name, u.last_name, u.memidnum from profile_user u join profile_ug ug on u.memidnum=ug.memidnum and ug.experiment=u.experiment where ug.experiment=? and ug.group_id=?
    order by u.last_name
    <sql:param value="${appVariables.experiment}"/>
    <sql:param value="${groupname}"/>
</sql:query>
    
<p id="pagelabel">Current project members:</p>
<c:forEach var="Row" items="${members.rows}">
    <a href="http://srs.slac.stanford.edu/GroupManager/exp/LSST-DESC/protected/user.jsp?memidnum=${Row.memidnum}">${Row.first_name} ${Row.last_name}</a><br/>
</c:forEach>

<%--

<display:table class="datatable" id="Row" name="${members.rows}">
    <c:if test="${!empty members.rows}">
        <display:column title="Name">
            <a href="http://srs.slac.stanford.edu/GroupManager/exp/LSST-DESC/protected/user.jsp?memidnum=${Row.memidnum}">${Row.first_name} ${Row.last_name}</a>
        </display:column>
    </c:if>
    <c:if test="${empty members.rows}">
        <display:column title="Name">
            No members
        </display:column>
    </c:if>
</display:table>
            
<c:set var="Rows" value="${members.rows}"/>

<table class="datatable">
    <c:if test="${!empty members.rows}">
        <utils:trEvenOdd reset="true"><th>Current Members</th>
        <td style="text-align: left"><a href="http://srs.slac.stanford.edu/GroupManager/exp/LSST-DESC/protected/user.jsp?memidnum=${Row.memidnum}">${Row.first_name} ${Row.last_name}</a></td>
        </utils:trEvenOdd>
    </c:if>
</table>
--%>
 
    
    