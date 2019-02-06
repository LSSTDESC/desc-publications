<%-- 
    Document   : publications
    Created on : Jun 30, 2017, 10:30:01 AM
    Author     : chee
--%>
<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib tagdir="/WEB-INF/tags/" prefix="tg"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions"  prefix="fn" %>
<%@taglib uri="http://displaytag.sf.net"  prefix="display" %>
<%@taglib uri="http://srs.slac.stanford.edu/displaytag" prefix="displayutils"  %>
<%@taglib uri="http://srs.slac.stanford.edu/GroupManager" prefix="gm" %>

<!DOCTYPE html>

<html>
 <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <link rel="stylesheet" href="css/site-demos.css">
    <link rel="stylesheet" href="css/pubstyles.css">
    <script src="js/jquery-1.11.1.min.js"></script>  
    <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>
    <script src="js/jquery.validate.min.js"></script>
    <title>LSST-DESC Create Project</title>
</head>

<body>

    <tg:underConstruction/>

    <c:choose>
    <c:when test="${( ! gm:isUserInGroup(pageContext,'lsst-desc-members') )}">  
        <%-- change this group once testing is over, to whatever group pub-board chooses as authorized --%>
        <c:redirect url="noPermission.jsp?errmsg=1"/>  
    </c:when>  
    <c:otherwise>
    <c:set var="candidategroup" value="lsst-desc-members"/>  
   
    <sql:query var="candidates">
        select me.memidnum, me.firstname, me.lastname, mu.username from um_member me join um_member_username mu on me.memidnum=mu.memidnum
        join um_project_members pm on me.memidnum=pm.memidnum join profile_ug ug on ug.memidnum=pm.memidnum and ug.group_id = ? 
        where pm.activestatus='Y' and pm.project = ?  and me.lastname != 'lsstdesc-user' order by lower(me.lastname)
        <sql:param value="${candidategroup}"/>
        <sql:param value="${appVariables.experiment}"/>
    </sql:query>
    
    <sql:query var="swgs">
        select id, name, profile_group_name as pgn, convener_group_name as cgn from descpub_swg where id = ?
        <sql:param value="${param.swgid}"/>
    </sql:query>
        
    <sql:query var="swgproj">
        select p.id, p.title, p.projectstatus, wg.name from descpub_project p join descpub_project_swgs ps on p.id=ps.project_id
        join descpub_swg wg on ps.swg_id=wg.id where p.id=? order by p.id
        <sql:param value="${param.id}"/>
    </sql:query>
        
    <sql:query var="detail">
        select id,title,summary,projectstatus,created from descpub_project where id=? 
        <sql:param value="${param.id}"/>
    </sql:query>
    
    <sql:query var="details">    
        select dp.title, dp.summary, dp.projectstatus, wg.name, wg.profile_group_name as pgn from 
        descpub_project dp join descpub_project_swgs sg on dp.id = sg.project_id join descpub_swg wg on wg.id = sg.swg_id
        where dp.id = ?
        <sql:param value="${param.id}"/>
    </sql:query>
        
    <sql:query var="srmact">
        select activity_id, title from descpub_srm_activities order by activity_id
    </sql:query>
        
    <sql:query var="srmdel">
        select deliverable_id, title from descpub_srm_deliverables order by deliverable_id
    </sql:query>
       
    <c:choose>  
        <c:when test="${param.task == 'create_proj_form'}">
             <h3>Working Group: ${swgs.rows[0].name}</h3><p/>
             <em id="pagerequire">* fields are required</em>
            <form name="addproject" id="addproject" action="project_details.jsp?task=addproject&swgid=${param.swgid}">
                <strong>* Title</strong><p/><input type="text" name="title" size="77" required/><p/>
                <strong>Confluence URL</strong><p/><input type="text" size="77" name="confluenceurl" id="confluenceurl" /><p/>
                <strong>Github URL</strong><p/><input type="text" size="77" name="gitspaceurl" id="gitspaceurl" /><p/>
                <strong>SRM activities</strong><p/>
                <select name="srmactivity" size="20" multiple>
                    <c:forEach var="s" items="${srmact.rows}">
                        <option value="${s.activity_id}">${s.activity_id} ${s.title}</option>
                    </c:forEach>
                </select>
                <p></p>
             <strong>SRM deliverables</strong><p/>
                <select name="srmdeliverable" size="20" multiple>
                    <c:forEach var="d" items="${srmdel.rows}">
                        <option value="${d.deliverable_id}">${d.deliverable_id} ${d.title}</option>
                    </c:forEach>
                </select>
                <p></p>
                <strong>* Summary<br/></strong><textarea rows="22" cols="80" name="summary" required></textarea>
                <p/>
                <strong>* Select project leads</strong><p/>
                <select name="addLeads" size="8" multiple required>
                    <c:forEach var="addrow" items="${candidates.rows}">
                        <option value="${addrow.memidnum}:${addrow.username}">${addrow.firstname} ${addrow.lastname}</option>
                    </c:forEach>
                </select>
                
                <input type="hidden" value="${param.swgid}" name="swgid"/><p/>
                <input type="hidden" value="Created" name="projectstatus"/><p/>
                <input type="hidden" value="true" name="formsubmitted"/><p/>
                <input type="submit" value="Create project" name="submit">
            </form>
                
            <script>
                $("#addproject").validate({
                    errorPlacement: function(error,element){
                        element.val(error.text());
                    }
                    errorClass: "my-error-class"
                }); 
            </script>
                
        </c:when>
        <c:when test="${param.formsubmitted == 'true'}">
                
            <c:set var="trapError" value=""/>
            <c:set var="newprojID" value=""/>
           
            <c:catch var="trapError">
                <sql:transaction>
                    <sql:update >
                    insert into descpub_project (id,title,summary,projectstatus,confluenceurl,gitspaceurl,created,createdby) values(DESCPUB_PROJ_SEQ.nextval,?,?,'Created',?,?,sysdate,?)
                    <sql:param value="${param.title}"/>
                    <sql:param value="${fn:escapeXml(param.summary)}"/>
                    <sql:param value="${fn:escapeXml(param.confluenceurl)}"/>
                    <sql:param value="${fn:escapeXml(param.gitspaceurl)}"/>
                    <sql:param value="${userName}"/>
                    </sql:update>
                    
                      <%-- get the new project id  --%> 
                    <sql:query var="projNum">
                        select descpub_proj_seq.currval as newProjNum from dual
                    </sql:query>  
                    <c:set var="newprojID" value="${projNum.rows[0]['newProjNum']}"/>
                    
                     <%-- add the project id - working group id since projects can have multiple working groups --%> 
                    <sql:update var="swg_proj">
                        insert into descpub_project_swgs (id,project_id,swg_id) values(descpub_proj_swg.nextval,?,?)
                        <sql:param value="${newprojID}"/>
                        <sql:param value="${param.swgid}"/>
                    </sql:update>
            
                    <%-- create the leadership group first since they will control the membership group for the project   --%>
                    <sql:update var="projleads">
                        insert into profile_group (group_name, group_manager, experiment) values (?,?,?)
                        <sql:param value="project_leads_${newprojID}"/>
                        <sql:param value="lsst-desc-publications-admin"/>
                        <sql:param value="${appVariables.experiment}"/>
                    </sql:update>
                        
                    <%-- project leaders manage the members, add the group and managing group to profile_ug  --%>  
                    <sql:update>
                        insert into profile_group (group_name, group_manager, experiment) values (?,?,?)
                        <sql:param value="project_${newprojID}"/>
                        <sql:param value="project_leads_${newprojID}"/>
                        <sql:param value="${appVariables.experiment}"/>
                    </sql:update>  
                      
                    <c:forEach var="x" items="${param}">  
                        <c:if test="${x.key == 'addLeads'}">
                            <c:forEach var="y" items="${paramValues[x.key]}">
                                <c:set var="array" value="${fn:split(y,':')}"/>
                                <sql:update var="leaders">
                                    insert into profile_ug (user_id, group_id, experiment, memidnum) values (?,?,?,?)
                                    <sql:param value="${array[1]}"/>
                                    <sql:param value="project_leads_${newprojID}"/>
                                    <sql:param value="${appVariables.experiment}"/>
                                    <sql:param value="${array[0]}"/>
                                </sql:update>
                                    
                                <sql:update var="leadersAsmembers">
                                    insert into profile_ug (user_id, group_id, experiment, memidnum) values (?,?,?,?)
                                    <sql:param value="${array[1]}"/>
                                    <sql:param value="project_${newprojID}"/>
                                    <sql:param value="${appVariables.experiment}"/>
                                    <sql:param value="${array[0]}"/>
                                </sql:update> 
                                    
                             </c:forEach>
                         </c:if>
                    </c:forEach>  
                                    
                    <c:forEach var="xx" items="${param}">
                      <c:choose>
                          <c:when test="${xx.key == 'srmactivity' && !empty paramValues[xx.key]}">
                             <c:forEach var="yy" items="${paramValues[xx.key]}">
                                <sql:query var="results">
                                    select title from descpub_srm_activities where activity_id = ?
                                    <sql:param value="${yy}"/>
                                </sql:query>
                                <sql:update var="act">
                                    insert into descpub_project_srm_info (project_id, srm_id, srmtype, srmtitle, entry_date) values (?, ?, 'activity', ?, sysdate)
                                    <sql:param value="${newprojID}"/>
                                    <sql:param value="${yy}"/>
                                    <sql:param value="${results.rows[0]['title']}"/>
                                </sql:update>
                             </c:forEach>
                          </c:when>
                          <c:when test="${xx.key == 'srmdeliverable' && !empty paramValues[xx.key]}">
                               <c:forEach var="yy" items="${paramValues[xx.key]}">
                                 <sql:query var="results">
                                    select title from descpub_srm_deliverables where deliverable_id = ?
                                    <sql:param value="${yy}"/>
                                 </sql:query>
                                 <sql:update var="del">
                                    insert into descpub_project_srm_info (project_id, srm_id, srmtype, srmtitle, entry_date) values (?, ?, 'deliverable', ?, sysdate)
                                    <sql:param value="${newprojID}"/>
                                    <sql:param value="${yy}"/>
                                    <sql:param value="${results.rows[0]['title']}"/>
                                </sql:update>
                                    <%--
                                 <sql:update var="del">
                                     insert into descpub_proj_deliverables (project_id,deliverable_id,del_title,entry_date)
                                     values(?,?,?,sysdate)
                                     <sql:param value="${newprojID}"/>
                                     <sql:param value="${yy}"/>
                                     <sql:param value="${results.rows[0]['title']}"/>
                                 </sql:update> --%>
                               </c:forEach>
                          </c:when>
                       </c:choose>
                    </c:forEach>             
                    
              </sql:transaction>
            </c:catch> 

            <c:if test="${!empty trapError}">
                Create project ${param.title} failed. insert into profile_group values(project_${newprojID}, project_leads_${newprojID}, ${appVariables.experiment})<br/>
                ${trapError}<p></p>
                <c:forEach var="par" items="${param}">
                    <c:out value="${par.key} = ${par.value}"/><br/>
                    <c:if test="${fn:contains(par.key,'srmactivity') || fn:contains(par.key,'srmdeliverable')}">
                        <c:forEach var="parval" items="${paramValues[par.key]}">
                            <c:out value="* paramValue: ${parval}"/><br/>
                        </c:forEach>
                    </c:if>
                </c:forEach>
            </c:if>
            <c:if test="${empty trapError}">
             <c:redirect url="show_project.jsp?projid=${projNum.rows[0]['newProjNum']}&swgid=${param.swgid}"/>  
                <%--
               Created ${param.title}<br/>
               <a href="show_swg.jsp?swgid=${param.swgid}">return to projects</a>
                --%>
            </c:if>    
        </c:when>
    </c:choose>
<p/>

<c:if test="${swg.rowCount > 0}">
    <hr align="left" width="50%"/>
    Project Members<p/>
    <tg:groupMemberEditor candidategroup="${swgs.rows[0].pgn}" groupname="${swgs.rows[0].cgn}" returnURL="project_details.jsp"/> 
</c:if>
 
<p/>
        </c:otherwise>
    </c:choose>
</body>
</html>
 
