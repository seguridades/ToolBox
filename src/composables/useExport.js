const HEADERS = ['Recurso', 'Sitio oficial', 'Repositorio', 'Precio', 'Código abierto', 'Plataformas']

function toRows(exportData) {
  return exportData.map((r) => [
    r.title ?? '',
    r.official_url ?? '—',
    r.repo_url ?? '—',
    r.pricing ?? '—',
    r.is_opensource ? 'Sí' : 'No',
    Array.isArray(r.platforms) ? r.platforms.join(', ') : '—',
  ])
}

export async function exportPDF(exportData, filename = 'maleta-de-taller') {
  const [{ default: jsPDF }, { default: autoTable }] = await Promise.all([
    import('jspdf'),
    import('jspdf-autotable'),
  ])

  const doc = new jsPDF({ orientation: 'landscape' })

  doc.setFontSize(14)
  doc.setFont('helvetica', 'bold')
  doc.text('Maleta de Taller — seguridades.org', 14, 16)

  doc.setFontSize(9)
  doc.setFont('helvetica', 'normal')
  doc.setTextColor(100)
  doc.text(`Generado el ${new Intl.DateTimeFormat('es').format(new Date())}`, 14, 22)

  autoTable(doc, {
    startY: 28,
    head: [HEADERS],
    body: toRows(exportData),
    styles: { fontSize: 8, cellPadding: 3 },
    headStyles: { fillColor: [93, 63, 211], textColor: 255, fontStyle: 'bold' },
    alternateRowStyles: { fillColor: [249, 250, 251] },
  })

  doc.save(`${filename}.pdf`)
}

export function exportCSV(exportData, filename = 'maleta-de-taller') {
  const rows = [HEADERS, ...toRows(exportData)]
  const csv  = rows.map((r) => r.map((cell) => `"${String(cell).replace(/"/g, '""')}"`).join(',')).join('\n')
  const blob = new Blob(['\uFEFF' + csv], { type: 'text/csv;charset=utf-8;' })
  const url  = URL.createObjectURL(blob)
  const a    = Object.assign(document.createElement('a'), { href: url, download: `${filename}.csv` })
  a.click()
  URL.revokeObjectURL(url)
}
