<%-- 
    Document   : editPublication
    Created on : Aug 8, 2017, 12:30:24 PM
    Author     : chee
--%>
<%@tag pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://srs.slac.stanford.edu/time" prefix="time"%>
<%@taglib uri="http://srs.slac.stanford.edu/GroupManager" prefix="gm"%>
<%@taglib tagdir="/WEB-INF/tags" prefix="tg"%>

<script src="js/jquery-1.11.1.min.js"></script>
<script src="js/jquery.validate.min.js"></script>
<link rel="stylesheet" href="css/pubstyles.css">

<%@attribute name="paperid" required="true"%>
 
<c:set var="paperleads" value="paper_leads_${paperid}"/> 

<sql:query var="states"> <%-- state here is really the doc status --%>
    select state from descpub_publication_states order by state
</sql:query>
    
  
<%-- get the values from the publication table --%>
<sql:query var="results">
    select * from descpub_publication where paperid = ?
    <sql:param value="${paperid}"/>
</sql:query>
    
<sql:query var="dateAdded">
    select to_char(createdate,'YYYY-Mon-DD HH:MI:SS') added from descpub_publication where paperid = ?
    <sql:param value="${paperid}"/>
</sql:query>
<c:set var="added" value="${dateAdded.rows[0].added}"/>
    
<%-- get the fields per pubtype --%>
<sql:query var="fi">
     select pb.metaid, pb.required, me.data, me.label, me.datatype, me.numrows, me.numcols, pb.sqlstr, pb.multiplevalues, pb.formposition from descpub_pubtype_fields pb join descpub_metadata me on pb.metaid = me.metaid
     where pb.pubtype = ? order by pb.formposition
     <sql:param value="${results.rows[0].pubtype}"/>
</sql:query>
     
<h3>DESC-${param.paperid} Title: ${results.rows[0].title} </h3>
    Project Id: <a href="show_project.jsp?projid=${results.rows[0].project_id}">${results.rows[0].project_id}</a> &nbsp; &nbsp; Doctype: ${results.rows[0].pubtype} &nbsp; &nbsp; Added: ${added}
    <c:if test="${!empty results.rows[0].moddate}">
        &nbsp; &nbsp;Last Modified: ${results.rows[0].moddate} &nbsp; &nbsp; &nbsp; &nbsp;
    </c:if>
  <p></p>      
 <form action="editPublication.jsp?paperid=${param.paperid}" method="post">
    <div id="formRequest">
        <fieldset class="fieldset-auto-width">
            <legend>Edit document</legend>
            
            <c:forEach var="x" items="${fi.rows}">
                 <c:if test="${!empty x.fieldexplanation}">
                     <p id="pagelabel">${x.fieldexplanation}</p>
                </c:if>
                     
                <c:if test="${x.datatype == 'string'}">
                   ${x.label} <input type="text" value="${results.rows[0][x.data]}" name="${x.data}" size="${fn:length(results.rows[0][x.data])}" ${x.required}/>
                   <p></p>
                </c:if>
                   
                <c:if test="${x.datatype == 'dropbox'}">
                    <sql:query var="res">
                        select metavalue, defaultvalue from descpub_metadata_enum where metaid = ?
                        <sql:param value="${x.metaid}"/>
                    </sql:query>  
                    ${x.label}:  
                    <select name="${x.data}" ${x.required}>
                        <c:forEach var="erow" items="${res.rows}">
                        <option value="${erow.metavalue}" <c:if test="${results.rows[0][x.data] == erow.metavalue}">selected</c:if> > ${erow.metavalue}</option>
                        </c:forEach>
                    </select> 
                    <p></p>
                </c:if>
                    
                <c:if test="${x.datatype == 'checkbox'}">
                    <sql:query var="enums">
                        select * from descpub_metadata_enum where metaid = ?
                        <sql:param value="${x.metaid}"/>
                    </sql:query>
                    <c:forEach var="chkbx" items="${enums.rows}">
                      ${chkbx.metavalue} <input type="checkbox" name="${x.data}" value="${chkbx.metavalue}" ${x.required}/><br/>
                    </c:forEach>
                    <p></p>
                </c:if>
                    
                <c:if test="${x.datatype == 'list'}">
                    <c:set var="selected" value=""/>
                    <sql:query var="res">
                       ${x.sqlstr}
                    </sql:query>   
                    <c:if test="${fn:contains(x.data,'current_institution')}">
                     ${x.label}
                     <select name="${x.data}" ${x.required}>
                         <c:forEach var="in" items="${res.rows}">
                             <option value="${in['institution']}" 
                                 <c:if test="${in['institution'] == results.rows[0][x.data]}">selected</c:if> > ${in['institution']} 
                             </option>
                         </c:forEach>
                     </select> 
                     </c:if>
                     <c:if test="${x.data == 'pubstatus'}">
                        ${x.label}
                         <select name="${x.data}" ${x.required}>
                            <option value=""></option>
                            <c:forEach var="st" items="${res.rows}">
                               <option value="${st['state']}" <c:if test="${results.rows[0][x.data] == st['state']}">selected</c:if> >${st['state']}</option>
                            </c:forEach>
                         </select>
                     </c:if>
                 <p></p>
                </c:if>
                 
                <c:if test="${x.datatype == 'textarea'}">
                   <sql:query var="rowcol">
                      select numrows, numcols from descpub_metadata where metaid = ?
                      <sql:param value="${x.metaid}"/>
                   </sql:query> 
                   ${x.label}:<br/><textarea rows="${rowcol.rows[0].numrows}" cols="${rowcol.rows[0].numcols}" name="${x.data}" ${x.required}>${results.rows[0][x.data]}</textarea><br/>
                 <p></p>
                </c:if>
                
                <c:if test="${x.datatype == 'url'}">
                    <c:choose>
                        <c:when test="${!empty results.rows[0][x.data]}">
                             ${x.label}: <input type="text" name="${x.data}" value="${results.rows[0][x.data]}" size="${fn:length(results.rows[0][x.data])}"/>
                        </c:when>
                        <c:otherwise>
                             ${x.label}: <input type="text" name="${x.data}" value="${results.rows[0][x.data]}" size="${x.numcols}"/>
                        </c:otherwise>
                    </c:choose>
                <p></p>
                </c:if>   
            </c:forEach>
            <input type="submit" name="submit" value="update"/>
        </fieldset>
    </div>
 </form>