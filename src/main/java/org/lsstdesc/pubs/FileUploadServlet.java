package org.lsstdesc.pubs;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.Iterator;
import java.util.Date;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.text.SimpleDateFormat;
import java.text.ParseException;

import org.srs.groupmanager.um.*;
import org.srs.web.base.db.WalletConnectionManager;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileUploadException;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

/**
 * A servlet for uploading documents using apache file upload
 *
 * @author tonyj
 */
public class FileUploadServlet extends HttpServlet {

    private File baseDir;

    @Override
    public void init() throws ServletException {
        super.init();
        baseDir = new File(getInitParameter("baseDir"));
    }

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response, String paperid, String projid, String wgid, String title, String remarks)
        throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        boolean isMultipart = ServletFileUpload.isMultipartContent(request);
        boolean isPDF = true;
        String today="";
        
//        try { today = getDate(); }
//        catch(Exception t){ System.out.println("getDate failed"); }
        
        System.out.println("isMultipart " + isMultipart);
        
        
        if (isMultipart) {
            PrintWriter out = response.getWriter();
            
            DiskFileItemFactory factory = new DiskFileItemFactory();
            ServletContext servletContext = this.getServletConfig().getServletContext();
            File repository = (File) servletContext.getAttribute("javax.servlet.context.tempdir");
            
            System.out.println("repository set to " + repository);
            factory.setRepository(repository);
//            ServletFileUpload upload = new ServletFileUpload(factory);
            ServletFileUpload uploadPub = new ServletFileUpload(factory);

            String forwardTo = null;
            List<String> attributeItems = new ArrayList<>();
            try {
                List<FileItem> items = uploadPub.parseRequest(request);

                for (FileItem item : items) {
//                    System.out.println("ITEM: " + item + " isFormField: " + item.isFormField());
//                    System.out.println("Item: " + item.getFieldName() +  " = " + item.getString() + "  isFormField=" + item.isFormField() );
                   
                    if (!item.isFormField()) {
//                        File file = new File(baseDir, item.getName());
                        File file = new File(item.getName());
                        String filename = file.toString();
                        byte[] b = new byte[4];
                        item.getInputStream().read(b);
                        if (b[0] != '%'  || b[1] != 'P' || b[2] != 'D' || b[3] != 'F'){
                            isPDF = false;
                            break;
                        } 
                        request.setAttribute("uploadflg",""); 
                        try {
//                            System.out.println("Attempt to write " + file + " to ~chee/pubTestDir/");
                            item.write(file);
                            updateDB(items, filename);
                            request.getSession().setAttribute("msg", "File saved as " + file + " paperid " + paperid + " title " + title);
                            request.setAttribute("uploadflg","done");
                        } catch (Exception ex) {
                            request.setAttribute("msg", "Error saving file " + ex);
                          }
                        } else if ("forwardTo".equals(item.getFieldName())) {
                        forwardTo = item.getString();
                    }
                }
                if (! isPDF) throw new ServletException("*** FILE IS NOT IN PDF FORMAT ***");

                if (forwardTo == null) throw new ServletException("Missing forwardTo parameter");
                // use sendRedirect because getRequestDispatcher does not update the url to the redirect page although the 'msg' is shown. Need to put 'msg' in the session
//                getServletContext().getRequestDispatcher(forwardTo).forward(request, response);
                response.sendRedirect(forwardTo);
            } catch (FileUploadException ex) {
                throw new ServletException("Error uploading file", ex);
            }

        } else {
            throw new ServletException("No file to upload");
        }
    }
 
    void  updateDB (List<FileItem> paramList, String filename) throws Exception {
             
            String paperid="";
            String projid="";
            String wgid="";
            String remarks="null";
            String maxVer="";
            String insStr = "";
            int currentversion= -1;
            
            for (FileItem item : paramList) {
                if ( item.getFieldName().contains("paperid") ){
                    paperid = item.getString();
                    maxVer = "select max(version) version from DESCPUB_PUBLICATION_VERSIONS where paperid = " + paperid;
                }
                if ( item.getFieldName().contains("projid") ){
                    projid = item.getString();
                }
                if ( item.getFieldName().contains("wgid") ){
                    wgid = item.getString();
                }  
                if ( item.getFieldName().contains("remarks") ){
                    remarks = item.getString();
                }  
            
            }
            System.out.println("PAPERID = " + paperid);
            System.out.println("PROJID = " + projid);
            System.out.println("WGID = " + wgid);
            System.out.println("FILENAME = " +  filename);
             
            try {
                String dbUrl = System.getProperty("groupmanager.db.url", "jdbc:oracle:thin:@sca-oracle01.slac.stanford.edu:1521:DPF01");
                String dbUsername = System.getProperty("groupmanager.db.username", "CONFIG");
                String dbPassword = System.getProperty("groupmanager.db.password", "M20177102Ay12");
                Connection connection = null;
                if (dbUrl.contains("oracle:oci")) {
                    WalletConnectionManager connectionManager = new WalletConnectionManager(dbUrl, "", "");
                    connection = connectionManager.getConnection();  

                    connection.setAutoCommit(false);
                    connection.commit();
                    connection.close();
                } 
            else {
                connection = DriverManager.getConnection(dbUrl, dbUsername, dbPassword);
                connection.setAutoCommit(false);
                // get the latest version number if it exists
                try( PreparedStatement stmt = connection.prepareStatement(maxVer) ){ 
                   ResultSet rs = stmt.executeQuery();
                   boolean hasVer = rs.next();
                   if (! hasVer){
                       System.out.println("has no max version " + hasVer ); 
                       currentversion = 1; 
                   }
                   else {
                       System.out.println("version " + rs.getInt("version"));
                       currentversion = rs.getInt("version") + 1;
                   }
                   
                   insStr="insert into descpub_publication_versions (paperid, tstamp, version, remarks, origname) values (" + paperid + ", sysdate, "  + currentversion + ", '" + remarks + "','" + filename + "')";
                   System.out.println(insStr);
                   PreparedStatement insertstmt = connection.prepareStatement(insStr);
                   insertstmt.execute() ;

                }
                catch(SQLException s){
                    System.out.println("SQL query failed with error " + s);
                }

                connection.commit();
                connection.close();
            }
                 
        }
        catch (Exception e){
            System.out.println("FAILED TO CONNECT TO DB");   
        }     
    }
    
//    private  String getDate () throws Exception {
//        Date curDate = new Date();
//        SimpleDateFormat format = new SimpleDateFormat();
//        format = new SimpleDateFormat("yyyy-M-dd-hh:mm:ss");
//        String DateToStr = format.format(curDate);
//    
//        return DateToStr;
//    }
//    
    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String paperid = request.getParameter("paperid");
        String projid = request.getParameter("projid");
        String wgid = request.getParameter("wgid");
        String title = request.getParameter("title");
        String remarks = request.getParameter("remarks");
        processRequest(request, response, paperid, projid, wgid, title, remarks);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        String paperid = request.getParameter("paperid");
        String projid = request.getParameter("projid");
        String wgid = request.getParameter("wgid");
        String title = request.getParameter("title");
        String remarks = request.getParameter("remarks");

        
        processRequest(request, response, paperid, projid, wgid, title, remarks);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>
}
