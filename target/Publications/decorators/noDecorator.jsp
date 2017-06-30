<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@ taglib uri="http://www.opensymphony.com/sitemesh/decorator" prefix="decorator" %>
<%@taglib prefix="dec" tagdir="/WEB-INF/tags/decorators" %>

<html>
    <head>
        <title>
            ${appVariables.experiment} ${applicationTitle} - <decorator:title default="Welcome!" />
        </title>
            <dec:style/>
        <decorator:head />
    </head>

    <body>
        <div class="pageBody">
            <decorator:body />
        </div>
    </body>
</html>
                