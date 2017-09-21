<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="f" uri="http://lsstdesc.org/functions" %>
<!DOCTYPE html>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" href="css/site-demos.css">
        <title>SWG</title>
    </head>
     <c:forEach var="x" items="${param}">
        <c:out value="Param: ${x.key}=${x.value}"/><br/>
    </c:forEach>
     
      
        <h1>Science Working Groups (SWG)</h1>
        
       <c:choose>
            <c:when test="${param.createswg == 'true'}">
                Enter name of SWG and and the listserv email address of the working group<br/>
                
                
                <form name="createSWG" action="swg.jsp" method="post">
                    Name: <input type="text" name="name" id="name" size="30"/><br/>
                    Profile Group Name: <input type="text" name="profileGrpName" id="profileGrpName" size="30"/><br/>
                    Listserv Email Address: <input type="text" name="email" id="email" size="30"/><br/>
                    <input type="hidden" value="true" name="formsubmitted"/>
                    <input type="submit" value="submit" name="submit"/>
                    <input type="reset" value="reset" name="reset"/>
                </form>
            </c:when>
            <c:when test="${param.formsubmitted =='true'}">
                insert into descpub_swg (id, name, email,profile_group_name) values(swg_seq.nextval,${param.name},${param.email},${param.profileGrpName})<br/>
                <sql:update var="ins">
                    insert into descpub_swg (id, name, email,profile_group_name) values(swg_seq.nextval,?,?,?)
                    <sql:param value="${param.name}"/>
                    <sql:param value="${param.email}"/>
                    <sql:param value="${param.profileGrpName}"/>
                </sql:update>  
            </c:when>
            <c:otherwise>
                swg created?
            </c:otherwise>
        </c:choose>
    
    
</html>
