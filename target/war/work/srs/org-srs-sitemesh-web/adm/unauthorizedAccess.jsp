<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
        <title>Unauthorized Access</title>
    </head>
    <body>
        <h1>Unauthorized Access</h1>
        <font size="3">

        The page you tried to access is restricted to only users in the following groups: 

    <c:forEach items="${paramValues.restrictedToGroup}" var="group">
        <b>${group}</b>&nbsp;&nbsp;
    </c:forEach>
    </br>
    </br>
    <c:set var="currentUser" value="${param.user}"/>
    <c:if test="${empty currentUser}">
        <c:set var="currentUser" value="${userName}"/>
    </c:if>    

    <c:if test="${empty currentUser}">
        You are currently not logged in. Please log in first by following this <a href="${appVariables.casBaseUrl}login?service=${param.service}">link</a>.</br>
        </br>
    </c:if>

    <c:if test="${! empty currentUser}">
        You are currently logged in as <b>${currentUser}</b>. Please contact <b>${param.administrator}</b> if you think you should be added to one of the above groups.</br>
    </c:if>
    </font>
</body>
</html>
