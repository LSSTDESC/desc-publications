<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql"%>
<%@taglib uri="http://srs.slac.stanford.edu/GroupManager" prefix="gm"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display"%>
<%@taglib uri="http://srs.slac.stanford.edu/displaytag" prefix="displayutils"%>
<%@taglib tagdir="/WEB-INF/tags/" prefix="tg"%>

<!DOCTYPE html>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <script src="js/jquery-1.11.1.min.js"></script>
        <script src="js/jquery.validate.min.js"></script>
        <link rel="stylesheet" href="css/pubstyles.css">
        <title>LSST DESC Publications Board</title>
    </head>
<body>
    
    <c:if test="${!(gm:isUserInGroup(pageContext,'GroupManagerAdmin') || gm:isUserInGroup(pageContext,'lsst-desc-members'))}">
        <c:redirect url="noPermission.jsp?errmsg=7"/>
    </c:if>  
    
    <tg:underConstruction/>
    
    <p/>
     <c:set var="convenLink" value="http://srs.slac.stanford.edu/GroupManager/exp/LSST-DESC/protected/group.jsp?name="/>
        
        <sql:query var="swgs">
            select id, name, profile_group_name as pgn, convener_group_name as cgn from descpub_swg order by name
        </sql:query>
             
        <%-- new select, order by journal paper --%>
        <sql:query var="papers">
        select paperid, project_id, pubtype, title, state, createdate, case when (modifydate > createdate and modifydate is not null) then modifydate 
        else createdate end as dt from descpub_publication where project_id != 0 order by dt desc
        </sql:query>
        
        <sql:query var="projectless"> 
          select p.paperid, pubtype, title, wg.name, createdate, case
          when (modifydate > createdate and modifydate is not null) then modifydate
          else createdate end as dt from descpub_publication p join descpub_publication_swgs s on p.paperid = s.paperid
          join descpub_swg wg on wg.id = s.swgid where project_id = 0 
        </sql:query>
            
        <c:if test="${swgs.rowCount > 0}">
            <display:table class="datatable"  id="Row" name="${swgs.rows}">
                <display:column title="Working Groups (WGs)" href="show_swg.jsp" paramId="swgid" property="name" paramProperty="id" sortable="true" headerClass="sortable" style="text-align:left;"/>
                <display:column title="Number of Projects (can be in multiple WGs)" style="text-align:left;">
                    <sql:query var="prow">
                    select count(project_id) tot from descpub_project_swgs where swg_id = ?
                    <sql:param value="${Row.id}"/>
                    </sql:query>
                    <c:if test="${prow.rows[0].tot > 0}">
                        ${prow.rows[0].tot}
                    </c:if>
                </display:column> 
            </display:table>
        </c:if>  
        <p></p>
        
        <c:if test="${projectless.rowCount > 0}">
           <p id="pagelabel">Most recently Updated Project-less Documents</p> 
           <display:table class="datatable" id="Line" name="${projectless.rows}" cellpadding="5" cellspacing="8">
               <display:column title="Doc Id" style="text-align:left;" sortable="true" headerClass="sortable" >
                   <a href="show_pub.jsp?paperid=${Line.paperid}">DESC-${Line.paperid} </a>
                </display:column>
                <display:column property="createdate" title="Created" style="text-align:left;" sortable="true" headerClass="sortable"/>
                <display:column property="dt" title="Last changed" style="" sortable="true" headerClass="sortable"/>
                <display:column property="title" title="Title" style="text-align:left;" sortable="true" headerClass="sortable"/>
                <display:column property="pubtype" title="Doc Type" style="text-align:left;" sortable="true" headerClass="sortable"/>
                <display:column property="name" title="Working group" style="text-align:left;" sortable="true" headerClass="sortable"/>
           </display:table>
        </c:if>
        
        <p></p>
        <c:if test="${papers.rowCount > 0}">
             <p id="pagelabel">Most recently Updated Project Documents</p> 
             <display:table class="datatable" id="Line" name="${papers.rows}" cellpadding="5" cellspacing="8">
                <display:column title="Doc Id" style="text-align:left;" sortable="true" headerClass="sortable" >
                   <a href="show_pub.jsp?paperid=${Line.paperid}">DESC-${Line.paperid} </a>
                </display:column>
                <display:column property="createdate" title="Created" style="text-align:left;" sortable="true" headerClass="sortable"/>
                <display:column property="dt" title="Last changed" style="" sortable="true" headerClass="sortable"/>
                <display:column property="state" title="Status" style="text-align:left;" sortable="true" headerClass="sortable"/>
                <display:column property="title" title="Title" style="text-align:left;" sortable="true" headerClass="sortable"/>
                <display:column property="pubtype" title="Doc Type" style="text-align:left;" sortable="true" headerClass="sortable"/>
                <display:column title="Project Id" style="text-align:left;" sortable="true" headerClass="sortable">
                    <c:if test="${Line.project_id > 0}">
                    <a href="projectView.jsp?projid=${Line.project_id}">${Line.project_id}</a>
                    </c:if>
                </display:column>
            </display:table>
        </c:if>        
    
        <c:if test="${pubs.rowCount > 0}">
           <display:table class="datatable" id="irow" name="${pubs.rows}"/>
        </c:if>
                    
    </body>

</html>
