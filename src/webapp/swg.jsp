<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="f" uri="http://lsstdesc.org/functions" %>
<!DOCTYPE html>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>SWG</title>
    </head>
    
        <h1>Science Working Groups (SWG)</h1>
        <a href="swg.jsp?create_swg=true">create swg</a>
        
        <c:choose>
            <c:when test="${param.create_swg =='true'}">
                <form name="createSWG">
                    <input type="text" name="name" id="name"/>
                    <input type="text" name="email" id="email"/>
                    <input type="submit" value="submit" name="create"/>
                </form>
            </c:when>
            <c:otherwise>
                <br/>swg main page
            </c:otherwise>
        </c:choose>
    
</html>
