<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>

<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib uri="http://srs.slac.stanford.edu/displaytag" prefix="displayutils" %>
<%@taglib uri="http://srs.slac.stanford.edu/utils" prefix="utils"%>
<%@taglib prefix="gm" uri="http://srs.slac.stanford.edu/GroupManager"%>
<%@taglib tagdir="/WEB-INF/tags" prefix="tg"%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" href="css/pubstyles.css">
    </head>
    <body>
        
        <tg:underConstruction/>
        
        <fmt:setTimeZone value="UTC"/>  
        <c:if test="${!empty msg}">
            <p id="pagelabel">${msg}</p> 
        </c:if>
         
        <c:if test="${!gm:isUserInGroup(pageContext,'lsst-desc-members')}">  
            <c:redirect url="noPermission.jsp?errmsg=7"/>
        </c:if>
            
        <c:set var="paperGrpName" value="paper_${param.paperid}"/>
        <c:set var="paperLeadGrpName" value="paper_leads_${param.paperid}"/>
        <%-- when testing against dev the tag gm:isUserInGroup won't work because it always checks against the prod db so test separately if user can edit paper.
        canEdit checks if conveners (primary auth) can edit, userCanEdit checks if member of the paper can edit
        --%>
        <c:set var="userCanEdit" value="false"/> <%-- can user edit --%>
        <c:set var="selectFields" value=""/> <%-- var to build list of fields per pubtype --%>
        <c:set var="primaryauths" value=""/>  
        
        <sql:query var="canUser"> <%-- check if user in either group --%>
          select memidnum from profile_ug where group_id in (?,?) and user_id=? and experiment = ?
          <sql:param value="${paperGrpName}"/>
          <sql:param value="${paperLeadGrpName}"/>
          <sql:param value="${userName}"/>
          <sql:param value="${appVariables.experiment}"/>
        </sql:query>
            
        <c:if test="${!empty canUser.rows[0].memidnum}">
             <c:set var="userCanEdit" value="true"/>
        </c:if> 
        
        <%-- build the list of fields appropriate for this pubtype --%>
        <sql:query var="fi">
            select pb.metaid, me.data, me.label, me.datatype, pb.multiplevalues, pb.formposition from descpub_pubtype_fields pb join descpub_metadata me on pb.metaid = me.metaid
            where pb.pubtype in (select pubtype from descpub_publication where paperid = ? )
            order by pb.formposition
            <sql:param value="${param.paperid}"/>
        </sql:query>
            
        <c:forEach var="f" items="${fi.rows}">
           <%--  <c:out value="F=${f.data}, ${f.label}"/><br> --%>
            <c:choose>
                <c:when test="${empty selectFields}">
                    <c:set var="selectFields" value="${f.data}"/>
                </c:when>
                <c:when test="${!empty selectFields}">
                    <c:set var="selectFields" value="${selectFields}, ${f.data}"/>
                </c:when>
            </c:choose>
        </c:forEach> 
        <%-- add on the pubtype and project_id --%>    
        <c:set var="selectFields" value="${selectFields}, pubtype, project_id"/>
            
        <%-- get the publication using the selectList. This list used to control what fields are displayed per pubtype --%> 
        <c:set var="qstr" value="select ${selectFields} from descpub_publication where paperid = ?"/>
        
        <sql:query var="pubs">
            ${qstr}
            <sql:param value="${param.paperid}"/>
        </sql:query> 
        <c:set var="projid" value="${pubs.rows[0].project_id}"/>
        <c:set var="pubtype" value="${fi.rows[0].pubtype}"/> 
        
        
        <%-- second pub query grabs all the details e.g. can_request_authorship --%>
        <sql:query var="pubDetails">
            select * from descpub_publication where paperid = ?
            <sql:param value="${param.paperid}"/>
        </sql:query>
        
        <%-- get the convener groupname --%>
        <sql:query var="leads">
           select  wg.id, wg.convener_group_name from descpub_project_swgs ps join descpub_swg wg on ps.swg_id = wg.id
           join descpub_publication dd on dd.project_id = ps.project_id where dd.paperid = ?
           <sql:param value="${param.paperid}"/>
        </sql:query>
           
        <%-- check if user is convener, do they have r/w access --%> 
        <c:forEach var="x" items="${leads.rows}">
            <c:if test="${gm:isUserInGroup(pageContext,x.convener_group_name)}">
                <c:set var="convenerCanEdit" value="true"/>
            </c:if>
        </c:forEach> 
        
        <h1>convenerCanEdit ${empty convenerCanEdit ? 'false' : 'true'}</h1>
        <sql:query var="countpapers">
            select count(*) from descpub_publication where project_id = ?
            <sql:param value="${projid}"/>
        </sql:query>   
      
        <%-- check for versions --%>
        <sql:query var="vers">
            select paperid, version, to_char(tstamp,'YYYY-Mon-DD HH:MI:SS') tstamp, to_char(tstamp,'YYYY-Mon-DD HH:MI:SS') pst, remarks from descpub_publication_versions where paperid=? order by version desc
            <sql:param value="${param.paperid}"/>
        </sql:query>
       
        <%-- get paper leads --%>
        <sql:query var="leadauth">
            select u.first_name, u.last_name, u.memidnum, u.user_name from profile_user u join profile_ug ug on u.memidnum = ug.memidnum and u.experiment = ug.experiment
            where ug.group_id = ? and ug.experiment = ? order by u.last_name
            <sql:param value="${paperLeadGrpName}"/>
            <sql:param value="${appVariables.experiment}"/>
        </sql:query>
            
        <c:forEach var="la" items="${leadauth.rows}">
            <c:choose>
                <c:when test="${empty primaryauths}">
                    <c:set var="primaryauths" value="${la.first_name}:${la.last_name}:${la.memidnum}"/>
                </c:when>
                <c:when test="${!empty primaryauths}">
                    <c:set var="primaryauths" value="${primaryauths},${la.first_name}:${la.last_name}:${la.memidnum}"/>
                </c:when>
            </c:choose>
        </c:forEach>
             
        <h2>Document: <strong>DESC-${param.paperid}</strong></h2> 
        <table class="datatable">
            <utils:trEvenOdd reset="true"><th style="text-align: left;">Document type</th><td style="text-align: left">${pubs.rows[0]['pubtype']}</td></utils:trEvenOdd>
            <utils:trEvenOdd reset="false"><th style="text-align: left">Project</th><td style="text-align: left">${pubs.rows[0]['project_id']}</td></utils:trEvenOdd>
            <c:forEach var="x" items="${pubs.columnNames}">
                <c:forEach var="f" items="${fi.rows}">
                    <c:if test="${fn:startsWith(fn:toLowerCase(x),fn:toLowerCase(f.label)) && fn:endsWith(fn:toLowerCase(x),fn:toLowerCase(f.label))}">
                        <utils:trEvenOdd reset="false"><th style="text-align: left">${f.label}</th><td style="text-align: left">${pubs.rows[0][f.data]}</td></utils:trEvenOdd>
                    </c:if>
                </c:forEach>
            </c:forEach>
            <utils:trEvenOdd reset="false"><th style="text-align: left">Lead authors</th>
                <td style="text-align: left">
                    <c:set var="parts" value="${fn:split(primaryauths,',')}"/>
                    <c:forEach var="p" items="${parts}" varStatus="status">
                        <c:set var="lead_author" value="${fn:split(p,':')}"/>
                        <a href="http://srs.slac.stanford.edu/GroupManager/exp/LSST-DESC/protected/user.jsp?memidnum=${lead_author[2]}">${lead_author[0]} ${lead_author[1]}&nbsp;</a>
                    </c:forEach>
                </td>
            </utils:trEvenOdd>

           <c:if test="${(pubDetails.rows[0].can_request_authorship == 'Y' && pubDetails.rows[0].state != 'inactive' && gm:isUserInGroup(pageContext,paperLeadGrpName) && userCanEdit==true)}">
               <utils:trEvenOdd reset="false"><th style="text-align: left">Request authorship</th>
                   <td style="text-align: left">
                   <a href="requestAuthorship.jsp?paperid=${param.paperid}">DESC-${param.paperid}</a>
                   </td>
               </utils:trEvenOdd>
           </c:if>       

           <c:if test="${userCanEdit || convenerCanEdit || gm:isUserInGroup(pageContext,paperGrpName) || gm:isUserInGroup(pageContext,paperLeadGrpName) || gm:isUserInGroup(pageContext,'GroupManagerAdmin') || gm:isUserInGroup(pageContext,'lsst-desc-publication-admin')}">
               <utils:trEvenOdd reset="false"><th style="text-align: left">Edit</th>
                   <td style="text-align: left">
                   <a href="editLink.jsp?paperid=${param.paperid}">DESC-${param.paperid}</a>
                   </td>
               </utils:trEvenOdd>
           </c:if>    
               
        </table>

        <c:if test="${vers.rowCount > 0}">
            <display:table class="datatable" id="row" name="${vers.rows}">
                <display:column title="Versions of DESC-${row.paperid}" sortable="true" headerClass="sortable">
                    <a href="download?paperid=${row.paperid}&version=${row.version}">Download version ${row.version}</a>
                </display:column>
                <display:column title="Remarks" property="remarks"/>
                <display:column title="Uploaded (UTC)">
                    ${row.tstamp}
                  <%-- <fmt:formatDate value="${row.tstamp}" pattern="yyyy-MM-dd HH:mm:ss"/> --%>
                </display:column>
            </display:table>
            <p/> 
        </c:if>
      
        <c:if test="${gm:isUserInGroup(pageContext,'lsst-desc-publications-admin') || gm:isUserInGroup(pageContext,paperLeadGrpName) || gm:isUserInGroup(pageContext,'GroupManagerAdmin') || gm:isUserInGroup(pageContext,'lsst-desc-publication-admin')}">
        <form action="upload.jsp" method="post" enctype="multipart/form-data">
            <div>
              <fieldset class="fieldset-auto-width">
                  <legend><strong>Upload</strong></legend><p/>
                  Upload new version of DESC-${param.paperid}<p/>
                  <input type="file" name="fileToUpload" id="fileToUpload"><p/>
                  Remarks: <input type="text" name="remarks" required><p/>
                  <input type="submit" value="Upload Document" name="submit">
                  <input type="hidden" name="forwardTo" value="/uploadPub.jsp?paperid=${param.paperid}" />
                  <input type="hidden" name="paperid" value="${param.paperid}"/>
              </fieldset>
            </div>
        </form>
        </c:if>
    </body>
</html>