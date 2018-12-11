<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://srs.slac.stanford.edu/GroupManager" prefix="gm" %>
<%@taglib uri="http://srs.slac.stanford.edu/displaytag" prefix="displayutils" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="utils" uri="http://srs.slac.stanford.edu/utils" %>
<%@taglib prefix="time" uri="http://srs.slac.stanford.edu/time" %>
<%@taglib tagdir="/WEB-INF/tags" prefix="g"%>

<html>
    <head>
        <title>Project Subscription Lists</title>
    </head>
    <body>

        <%--
    <c:forEach var="p" items="${param}">
           <h3>p: ${p.key}=${p.value} param[user_name]=${param['user_name']} userName=${userName}</h3>
    </c:forEach>
    <c:if test="${!empty paramValues.subscribetolist}">
       <c:forEach var="pv" items="${paramValues.subscribetolist}">
           <h4>pv: ${pv}</h4>
       </c:forEach>
    </c:if> --%>
    
    <%-- Decide who's record is to be displayed. param.USERNAME indicates a just updated mailrecord for a
    selected project member.  UserName is the user of the site. param.user_name is a member selected
    from the member list by a project administrator. effectiveUser is the name of the desired user selected. If user
    selected 'reset' then redisplay with the current user selected.
    --%>    
   <c:choose>
       <c:when test="${param.action == 'Reset'}">
          <c:set var="effectiveUser" value="${param.action == 'Reset' ? userName : param.user_name}"/> 
       </c:when>
       <c:when test="${!empty param.useName}">
          <c:set var="effectiveUser" value="${param.useName}"/> 
       </c:when>
       <c:when test="${!empty param.user_name}">
          <c:set var="effectiveUser" value="${param.user_name}"/> 
       </c:when>
       <c:when test="${empty param.useName && empty effectiveUser}">
          <c:set var="effectiveUser" value="${userName}"/>
       </c:when>
   </c:choose>
    
   <c:set var="USERNAME" value="${effectiveUser}"/>
   <sql:query var="memid">
       select memidnum from profile_user where user_name = ?
       <sql:param value="${effectiveUser}"/>
   </sql:query>
   <c:set var="memidnum" value="${memid.rows[0].memidnum}"/> 
   
   <c:set var="debugMode" value="true"/>
   <c:choose>
        <c:when test="${debugMode == 'false'}">
           <c:set var="IsAdmin" value="${ gm:isUserInGroup(pageContext,'lsst-desc-publications-admin') ||  gm:isUserInGroup(pageContext,'GroupManagerAdmin')  }"/> 
        </c:when>
        <c:when test="${debugMode == 'true'}">
           <c:set var="IsAdmin" value="${gm:isUserInGroup(pageContext,'TESTLIST')}"/>
        </c:when>
   </c:choose>

   <c:choose>
       <c:when test="${gm:isUserInExperiment(pageContext)}">
        <sql:query var="projectList">
           select id, title from descpub_project order by id desc
        </sql:query>
           
        <c:set var="selected" value="false"/>

        <%-- get name of member to display on web page--%>
        <sql:query var="projectmem"  >
            select first_name,last_name from profile_user where experiment =?
            <sql:param value="${appVariables.experiment}"/>
            and lower(slac_username) = lower(?)
            <sql:param value="${USERNAME}"/> 
        </sql:query>
            
        <c:if test= "${!empty param.modifyLists}"> 
            <%--delete user from all projects first then add back lists being subscribed  --%>
             
           <c:forEach var="row" items="${projectList.rows}">
               <sql:update> delete profile_ug where memidnum = ? and group_id=?
                   and experiment = ?
                   <sql:param value="${memidnum}"/>
                   <sql:param value="project_${row.id}"/>
                   <sql:param value="${appVariables.experiment}"/>
               </sql:update> 
           </c:forEach>

           <%-- add user to projects selected --%>  
           <c:forEach var="proj_list" items="${paramValues.subscribetolist}" varStatus="theCount" >
              <c:if test="${fn:length(proj_list) > 0}">
                  <c:set var="list_of_projLists" value="${list_of_projLists}, ${proj_list}"/>
              </c:if>
              <sql:update>  
                 insert into profile_ug (user_id,group_id,experiment,memidnum) values(?,?,?,?)
                 <sql:param value="${USERNAME}"/>
                 <sql:param value="project_${proj_list}"/>
                 <sql:param value="${appVariables.experiment}"/>
                 <sql:param value="${memidnum}"/>
             </sql:update>   
             <c:set var="count" value="${theCount.index + 1}" scope="page"/>    
           </c:forEach> 
                    
           <h3>Successfully updated subscription list. Current subscriptions: ${count}</h3>         
        </c:if> 
        
        <c:if test="${empty param.modifyLists}">
            <h3> Project subscription list for ${projectmem.rows[0]['first_name']} ${projectmem.rows[0]['last_name']}  </h3>

            <form name="projectlist"  action="projectSubscriptions.jsp" method="post"> 
                <display:table class="datatable" id="Row" name="${projectList.rows}" defaultorder="ascending">
                    <display:column property="id" title="Project ID">
                        project_${Row.id}
                    </display:column>

                    <display:column title="List of Projects" style="text-align:left" sortable="true" sortProperty="group_name" headerClass="sortable" >                    
                         ${Row.title}                   
                    </display:column>
                    <display:column  title="Subscribed">
                        <sql:query var="inList">
                            select g.user_id from profile_ug g where g.group_id = ? and g.memidnum = ? and experiment = ?
                            <sql:param value="project_${Row.id}"/>
                            <sql:param value="${memidnum}"/>                
                            <sql:param value="${appVariables.experiment}"/>
                        </sql:query>

                        <%-- restricted list checkbox set to readonly so the value is retained, otherwise the user is deleted from that list--%> 
                        <c:if test="${inList.rowCount == 0}">
                            <input type="checkbox" name="subscribetolist" value="${Row.id}"/>
                        </c:if>           
                        <c:if test="${inList.rowCount > 0}">
                            <input type="checkbox" name="subscribetolist" value="${Row.id}" checked />
                        </c:if> 
                    </display:column>  
                </display:table> 
                <input type="hidden" value="${USERNAME}" name="useName"/>
                <input type="hidden" value="${memidnum}" name="memidnum"/>
                <input type="hidden" value="Y" name="modifyLists"/>
                <input type="submit" value="Apply Changes" name="submit"/>
            </form>  
        </c:if>
       </c:when>
       <c:otherwise>
            This page can be accessed only by users in ${appVariables.experiment}
       </c:otherwise>
   </c:choose>        