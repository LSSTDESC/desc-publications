<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://srs.slac.stanford.edu/displaytag" prefix="displayutils" %>
<%@taglib prefix="gm" uri="http://srs.slac.stanford.edu/GroupManager"%>

<!DOCTYPE html>
<html>
 <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
      <link rel="stylesheet" href="css/site-demos.css">
      <title>Institution Information for ${param.institution}</title>
</head>

<body>
    
    <c:choose>
        <c:when test="${! empty param.name}">
        <sql:query var="ins">
            select institution, street_address, country from um_institutions where institution = ? 
            <sql:param value="${param.name}"/>
        </sql:query>
         <form name="insti" action="show_institution.jsp?Iformsubmitted=true">
            Name: <input type="text" name="name" id="name" size="50" value="${ins.rows[0].institution}"/><br/>
            Address: <input type="text" name="addr" id="addr" size="50" value="${ins.rows[0].street_address}"/><br/>
            Country: <input type="text" name="country" id="country" size="50" value="${ins.rows[0].country}"/><br/>
            <input type="hidden" value="true" name="Iformsubmitted"/>
            <input type="submit" value="submit" name="submit"/>
            <input type="reset" value="reset" name="reset"/>
        </form>   
        </c:when> 
        <c:when test="${!empty param.Iformsubmitted}">
            <c:forEach var="x" items="${param}">
                <c:out value="${x.key}=${x.value}"/>
            </c:forEach>
        </c:when>
    </c:choose>
</body>
</html>