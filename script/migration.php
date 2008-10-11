<?php
	include('/var/www/cms-svntest/lib/adodb/adodb.inc.php');
	$psql = ADONewConnection('postgres7');
	$psql->debug = true;
	$psql->Connect('localhost', 'gforge', 'gforge', 'gforge');

	$mysql = ADONewConnection('mysql');
	$mysql->debug = true;
	$mysql->Connect('localhost', 'root', 'nip_hair', 'cmsforge_development');

	#Groups -> Projects
	$mysql->Execute('DELETE FROM projects');
	$rs = $psql->Execute('select * from groups');

	while (!$rs->EOF)
	{
		$time = $rs->fields['register_time'];
		$query = "INSERT INTO projects (id, name, unix_name, description, registration_reason, project_type, project_category, created_at, updated_at, is_active, state, reject_reason, license_id) values (?, ?, ?, ?, ?, '', '', ".$mysql->DBTimeStamp($time).", ".$mysql->DBTimeStamp($time).", 1, ?, ?, ?)";
		$mysql->Execute($query, array(
			$rs->fields['group_id'], 
			$rs->fields['group_name'], 
			$rs->fields['unix_group_name'], 
			$rs->fields['short_description'], 
			$rs->fields['register_purpose'], 
			($rs->fields['status'] == 'A' ? 'approved' : 'rejected'), 
			'', 
			$rs->fields['license']
		));
		$rs->MoveNext();
	}

	$rs->Close();
	
	#Users -> Users
	$mysql->Execute('DELETE FROM users');
	$rs = $psql->Execute('select * from users');

	while (!$rs->EOF)
	{
		$time = $rs->fields['add_date'];
		$query = "INSERT INTO users (id, login, email, crypted_password, salt, created_at, updated_at, activation_code, activated_at, remember_token, remember_token_expires_at, superuser, full_name) values (?, ?, ?, ?, ?, ".$mysql->DBTimeStamp($time).", ".$mysql->DBTimeStamp($time).", ?, ".$mysql->DBTimeStamp($time).", '', now(), 0, ?)";
		$mysql->Execute($query, array(
			$rs->fields['user_id'], 
			$rs->fields['user_name'], 
			$rs->fields['email'], 
			$rs->fields['user_pw'], 
			'', 
			$rs->fields['confirm_hash'],
			$rs->fields['realname']
		));
		$rs->MoveNext();
	}

	$rs->Close();

	#user_group -> assignments
	$mysql->Execute('DELETE FROM assignments');
	$rs = $psql->Execute('select ug.*, r.role_name from user_group ug left outer join role r on r.group_id = ug.group_id and r.role_id = ug.role_id');

	while (!$rs->EOF)
	{
		$query = "INSERT INTO assignments (id, project_id, user_id, role, created_at, updated_at) values (?, ?, ?, ?, now(), now())";
		$role = 'Member';
		if ($rs->fields['role_name'] == '' || $rs->fields['role_name'] == 'Admin')
		{
			$role = 'Administrator';
		}
		$mysql->Execute($query, array(
			$rs->fields['user_group_id'],
			$rs->fields['group_id'],
			$rs->fields['user_id'],
			$role
		));
		$rs->MoveNext();
	}

	$rs->Close();

	#frs_package -> packages
	$mysql->Execute('DELETE FROM packages');
	$rs = $psql->Execute('select * from frs_package');

	while (!$rs->EOF)
	{
		$query = "INSERT INTO packages (id, project_id, name, is_public, is_active, created_at, updated_at) values (?, ?, ?, ?, ?, now(), now())";
		$mysql->Execute($query, array(
			$rs->fields['package_id'],
			$rs->fields['group_id'],
			$rs->fields['name'],
			$rs->fields['is_public'],
			$rs->fields['status_id']
		));
		$rs->MoveNext();
	}

	$rs->Close();

	#frs_release -> releases
	$mysql->Execute('DELETE FROM releases');
	$rs = $psql->Execute('select * from frs_release');

	while (!$rs->EOF)
	{
		$time = $rs->fields['release_date'];
		$query = "INSERT INTO releases (id, package_id, name, release_notes, changelog, released_by, is_active, created_at, updated_at) values (?, ?, ?, ?, ?, ?, ?, ".$mysql->DBTimeStamp($time).", ".$mysql->DBTimeStamp($time).")";
		$mysql->Execute($query, array(
			$rs->fields['release_id'],
			$rs->fields['package_id'],
			$rs->fields['name'],
			$rs->fields['notes'],
			$rs->fields['changes'],
			$rs->fields['released_by'],
			($rs->fields['status_id'] == '3' ? 0 : 1)
		));
		$rs->MoveNext();
	}

	$rs->Close();

	#bug versions
	$mysql->Execute('DELETE FROM bug_versions');
	$rs = $psql->Execute("select gl.group_id, efe.element_id, efe.element_name from artifact_group_list gl inner join artifact_extra_field_list efl on efl.group_artifact_id = gl.group_artifact_id inner join artifact_extra_field_elements efe on efe.extra_field_id = efl.extra_field_id where gl.name = 'Bugs' and efl.field_name = 'Version'");

	while (!$rs->EOF)
	{
		$query = "INSERT INTO bug_versions (project_id, name, created_at, updated_at) values (?, ?, now(), now())";
		$mysql->Execute($query, array(
			$rs->fields['group_id'],
			$rs->fields['element_name']
		));
		$rs->MoveNext();
	}

	$rs->Close();

	
	#artifacts -> bugs
	$mysql->Execute('DELETE FROM tracker_items');
	$rs = $psql->Execute("select name, a.*, gl.group_id, s.status_name from artifact a inner join artifact_group_list gl on gl.group_artifact_id = a.group_artifact_id inner join artifact_status s on s.id = a.status_id where name = 'Bugs' or name = 'Feature Requests'");

	while (!$rs->EOF)
	{
		$created = $rs->fields['open_date'];
		$updated = $rs->fields['last_modified_date'];
		$type = 'Bug';
		if ($rs->fields['name'] == 'Feature Requests')
		{
			$type = 'FeatureRequest';
		}
		$query = "INSERT INTO tracker_items (id, project_id, assigned_to_id, version_id, created_by_id, state, summary, description, created_at, updated_at, type) values (?, ?, ?, ?, ?, ?, ?, ?, ".$mysql->DBTimeStamp($created).", ".$mysql->DBTimeStamp($updated).", ?)";
		$mysql->Execute($query, array(
			$rs->fields['artifact_id'],
			$rs->fields['group_id'],
			$rs->fields['assigned_to'],
			-1,
			$rs->fields['submitted_by'],
			$rs->fields['status_name'],
			$rs->fields['summary'],
			$rs->fields['details'],
			$type
		));
		$rs->MoveNext();
	}

	$rs->Close();

	#artifacts details
	$rs = $mysql->Execute('SELECT * FROM tracker_items');
	while (!$rs->EOF)
	{
		$project_id = $rs->fields['project_id'];
		$bug_id = $rs->fields['id'];

		$rs2 = $psql->Execute("select artifact_extra_field_data.*, artifact_extra_field_list.field_name, artifact_extra_field_elements.element_name from artifact_extra_field_data inner join artifact_extra_field_elements on artifact_extra_field_data.field_data = artifact_extra_field_elements.element_id and artifact_extra_field_elements.extra_field_id = artifact_extra_field_data.extra_field_id inner join artifact_extra_field_list on artifact_extra_field_list.extra_field_id = artifact_extra_field_data.extra_field_id WHERE artifact_extra_field_data.artifact_id = ?", array($bug_id));
		while (!$rs2->EOF)
		{
			$field_name = $rs2->fields['field_name'];
			$element_name = $rs2->fields['element_name'];
			if ($field_name == 'Version')
			{
				$version_id = $mysql->GetOne('SELECT id from bug_versions WHERE project_id = ? AND name = ?', array($project_id, $element_name));
				$mysql->Execute('UPDATE tracker_items SET version_id = ? WHERE id = ?', array($version_id, $bug_id));
			}
			if ($field_name == 'Severity')
			{
				if ($element_name == 'blocker') $element_name = 'Critical';
				if ($element_name == 'enhancement') $element_name = 'None';
				$severity_id = $mysql->GetOne('SELECT id FROM enumrecords WHERE name = ? AND type = ?', array($element_name, 'BugSeverity'));
				$mysql->Execute('UPDATE tracker_items SET severity_id = ? WHERE id = ?', array($severity_id, $bug_id));
			}
			if ($field_name == 'Resolution')
			{
				$resolution_id = $mysql->GetOne('SELECT id FROM enumrecords WHERE name = ? AND type = ?', array($element_name, 'BugResolution'));
				$mysql->Execute('UPDATE tracker_items SET resolution_id = ? WHERE id = ?', array($resolution_id, $bug_id));
			}
			$rs2->MoveNext();
		}
		$rs2->Close();

		$rs->MoveNext();	
	}
	$rs->Close();

	#artifact_message -> comments
	$mysql->Execute('DELETE FROM comments');
	$rs = $psql->Execute("SELECT * FROM artifact_message");

	while (!$rs->EOF)
	{
		$created = $rs->fields['adddate'];
		$query = "INSERT INTO comments (title, comment, commentable_id, commentable_type, user_id, created_at) VALUES (?, ?, ?, ?, ?, ".$mysql->DBTimeStamp($created).")";
		$mysql->Execute($query, array(
			'',
			$rs->fields['body'],
			$rs->fields['artifact_id'],
			'Bug',
			$rs->fields['submitted_by']
		));
		$rs->MoveNext();
	}

	$rs->Close();

	#frs_file -> ReleasedFiles
	$mysql->Execute('DELETE FROM released_files');
	$rs = $psql->Execute('select frs_file.file_id, frs_file.release_id, frs_file.filename, frs_file.file_size, frs_file.release_time, count(frs_dlstats_file.file_id) as dl_count from frs_file inner join frs_dlstats_file on frs_dlstats_file.file_id = frs_file.file_id group by frs_file.file_id, frs_file.filename, frs_file.release_id, frs_file.file_size, frs_file.release_time');

	while (!$rs->EOF)
	{
		$time = $rs->fields['release_time'];
		$query = "INSERT INTO released_files (id, release_id, filename, filesize, downloads, created_at, updated_at) values (?, ?, ?, ?, ?, ".$mysql->DBTimeStamp($time).", ".$mysql->DBTimeStamp($time).")";
		$mysql->Execute($query, array(
			$rs->fields['file_id'], 
			$rs->fields['release_id'], 
			$rs->fields['filename'], 
			$rs->fields['file_size'],
			$rs->fields['dl_count']
		));
		$rs->MoveNext();
	}
	$rs->Close();

	$mysql->Close();
	$psql->Close();
?>
