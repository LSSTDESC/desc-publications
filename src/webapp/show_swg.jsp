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
<%@taglib uri="http://srs.slac.stanford.edu/displaytag" prefix="displayutils" %>
<%@taglib prefix="gm" uri="http://srs.slac.stanford.edu/GroupManager"%>

<!DOCTYPE html>

 <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
      <link rel="stylesheet" href="css/site-demos.css">
      <title>SWG Page</title>
</head>

<body>

    <h2>Science Working Groups ${param.swgname}</h2>
    
    <sql:query var="swgs" dataSource="jdbc/config-dev">
        select id, name, email, profile_group_name as pgn, convener_group_name as cgn from descpub_swg order by id
    </sql:query>
   
    <c:forEach var="x" items="${param}">
        <c:out value="Param: ${x.key}=${x.value}"/><br/>
    </c:forEach>
        
    <c:choose> 
        <c:when test="${empty param}">
            <a href="swg.jsp?createswg=true">create swg</a><br/>
            <c:if test="${swgs.rowCount > 0}">
                <display:table class="datatable"  id="Row" name="${swgs.rows}">
                    <display:column title="Id" sortable="true" headerClass="sortable">
                        ${Row.id}
                    </display:column>
                    <display:column title="Working Group" sortable="true" headerClass="sortable">
                        <a href="show_swg.jsp?detail_id=${Row.id}">${Row.name}</a>
                    </display:column>
                    <display:column title="Mail List" sortable="true" headerClass="sortable">
                        <a href="mailto:${Row.email}">${Row.email}</a>
                    </display:column>
                    <display:column title="Conveners" sortable="true" headerClass="sortable">
                        <sql:query var="conveners" dataSource="jdbc/config-dev">
                            select me.firstname, me.lastname from um_member me join profile_ug ug on me.memidnum=ug.memidnum and ug.group_id=?
                            <sql:param value="${Row.cgn}"/>
                        </sql:query>
                        <c:if test="${conveners.rowCount>0}">
                           <display:table class="datatable" id="cRow" name="${conveners.rows}"/>
                        </c:if>
                    </display:column>
                </display:table>
            </c:if>
        </c:when>
        <c:when test="${!empty param.detail_id}">
              go to details page for ${Row.name}
        </c:when>
         
        <c:otherwise>
            nothing to do
        </c:otherwise>
    </c:choose>    

    
</body>
</html>
    
    
</html>
