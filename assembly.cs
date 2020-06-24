var commonAssembly      = System.Reflection.Assembly.LoadFile(@"E:\_temp\SMAT_RTM_Update6_1\SMAT_RTM_Update6_1\Microsoft.SharePoint.Migration.Scan.Common.dll");
var scannerAssembly     = System.Reflection.Assembly.LoadFile(@"E:\_temp\SMAT_RTM_Update6_1\SMAT_RTM_Update6_1\Microsoft.SharePoint.Migration.Scan.Scanners.dll");
var scannerCoreAssembly = System.Reflection.Assembly.LoadFile(@"E:\_temp\SMAT_RTM_Update6_1\SMAT_RTM_Update6_1\Microsoft.SharePoint.Migration.Scan.Scanners.Core.dll");

var scannerDefinition   = new ScannerDefinition();
var scanners = scannerAssembly.GetTypes().Concat(scannerCoreAssembly.GetTypes());

var results = new Dictionary<string,string>();

foreach( var scanner in scanners )
{
	if( null != scanner.BaseType && (scanner.BaseType.FullName == typeof(DatabaseScanner).FullName) )
	{
		try
		{
			var instance = Activator.CreateInstance(scanner, scannerDefinition, @"E:\_temp\SMAT_RTM_Update6_1\SMAT_RTM_Update6_1\");
			if( null == instance ) continue;
			
			var property = scanner.GetProperty("ViolatorQuery");
			if( null == property ) continue;

			var value = property.GetValue(instance, null);
			if( null == value ) continue;

			results.Add(scanner.FullName, value.ToString());
		}
		catch(Exception ex)
		{
			$"Scanner: {scanner.FullName}. Exception: {ex.ToString()}".Dump();
		}
	}
}

var sb = new System.Text.StringBuilder();

foreach( var result in results )
{
	sb.AppendLine(string.Format("{0},\"{1}\"", result.Key, result.Value.Trim('\r').Trim('\n')));	
}

File.WriteAllText("E:\\_temp\\smat_queries.csv", sb.ToString());