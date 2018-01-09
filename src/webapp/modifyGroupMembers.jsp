<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://srs.slac.stanford.edu/GroupManager" prefix="gm" %>

<html>
    <head>
        <title>${appVariables.experiment} Group Manager: Modify </title>
    </head>
    <body>
         
    <c:if test="${!(gm:isUserInGroup(pageContext,'GroupManagerAdmin') || gm:isUserInGroup(pageContext,param.groupname))}">
        <c:redirect url="noPermission.jsp?errmsg=1"/>
    </c:if>  
        
   <%-- groups must have at least one member --%>   
    <sql:query var="checkcnt">
        select count(*) tot from profile_ug where group_id = ?
        <sql:param value="${param.groupname}"/>
    </sql:query>
      
    <c:if test="${checkcnt.rows[0].tot == fn:length(paramValues.removeMember) && param.action != 'Join'}">
        <c:redirect url="noPermission.jsp?errmsg=6"/> 
    </c:if>   
         
    <c:choose>
        <c:when test="${gm:isUserInExperiment(pageContext)}">  
            <c:choose>
                <c:when test="${param.action=='Leave'}">
                    <c:forEach var="line" items="${paramValues['removeMember']}">
                        <c:set var="userVals" value="${fn:split(line,':')}"/>  
                        <c:set var="memidnum" value="${userVals[0]}"/>
                        <c:set var="uid" value="${userVals[1]}"/>
                        <sql:update >
                            DELETE FROM PROFILE_UG WHERE MEMIDNUM=? AND GROUP_ID=? AND EXPERIMENT=? AND USER_ID=?
                            <sql:param value="${memidnum}"/>
                            <sql:param value="${param.groupname}"/>
                            <sql:param value="${appVariables.experiment}"/>
                            <sql:param value="${uid}"/>
                        </sql:update>   
                    </c:forEach>
                </c:when>
                <c:when test="${param.action=='Join'}">
                    <c:forEach var="user" items="${paramValues['addMember']}">
                        <c:set var="userVals" value="${fn:split(user,':')}"/>  
                        <c:set var="memidnum" value="${userVals[0]}"/>
                        <c:set var="uid" value="${userVals[1]}"/>
                        <c:if test="${!empty uid && !empty param.groupname && !empty memidnum}">
                        <sql:update>
                            INSERT INTO PROFILE_UG (USER_ID,GROUP_ID,EXPERIMENT,MEMIDNUM) VALUES(?,?,?,?)
                            <sql:param value="${uid}"/>
                            <sql:param value="${param.groupname}"/>
                            <sql:param value="${appVariables.experiment}"/>
                            <sql:param value="${memidnum}"/>
                        </sql:update> 
                        </c:if>  
                        <c:if test="${empty uid || empty param.groupname || empty memidnum}">
                            One of uid, groupname or memidnum is empty:
                            ${uid}<br/>
                            ${param.groupname}<br/>
                            ${memidnum}<br/>
                            No update done<br/>
                            returnURL = ${param.returnURL}<br/>
                            <c:redirect url="${param.returnURL}"/>
                        </c:if>     
                    </c:forEach>
                </c:when>
            </c:choose> 
           <c:redirect url="${param.returnURL}"/>  
        </c:when>
    </c:choose>
    
    </body>
</html>
    
