package org.lsstdesc.pubs;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author tonyj
 */
public class FileDownloadServlet extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int paperId = Integer.parseInt(request.getParameter("paperId"));
        int version = Integer.parseInt(request.getParameter("version"));
        try {
            File serverFile;
            try (Connection conn = ConnectionManager.getConnection(request)) {
                DBUtilities dbUtil = new DBUtilities(conn);
                serverFile = dbUtil.getFile(paperId, version);
            }
            response.setContentType("application/pdf");
            response.setHeader( "Content-Disposition", "attachment;filename=" + serverFile.getName());
            response.setContentLength((int) serverFile.length());
            byte[] buffer = new byte[65536];
            try (ServletOutputStream out = response.getOutputStream()) {
                try (InputStream in = new FileInputStream(serverFile)) {
                    for (;;) {
                        int l = in.read(buffer);
                        if (l<0) break;
                        out.write(buffer,0,l);
                    }
                }
            }
        } catch (SQLException x) {
            throw new ServletException("Error downloading file", x);
        }
    }

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
        processRequest(request, response);
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
        processRequest(request, response);
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
