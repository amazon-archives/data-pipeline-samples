# EFSBackup

#####A collection of AWS Data Pipeline templates and scripts used to backup & restore Amazon EFS file systems

If you need to be able to recover from unintended changes or deletions in your Amazon EFS file systems, you'll need to implement a backup solution. Once such backup solution is presented in the EFS documentation, and can be found here: http://docs.aws.amazon.com/efs/latest/ug/efs-backup.html.

In that backup solution, you'll create an AWS Data Pipeline to copy data from your Amazon EFS file system (called the production file system) to another Amazon EFS file system (called the backup file system). This solution consists of AWS Data Pipeline templates that implement the following:

<ul>
  <li>Automated EFS backups based on a schedule you define (hourly, daily, weekly, or monthly).</li>
  <li>Automated rotation of the backups, where the oldest backup is replaced with the newest backup based on the number of backups you want to retain.</li>
  <li>Quicker backups using rsync to only backup changes from one backup to the next.</li>
  <li>Efficient storage of backups using hard links (a hard link is a directory entry that associates a name with a file in a file system). This gives you the ability to perform a full restoration of data from any backup, while only storing what changed from backup to backup.</li>
</ul>


## Parameters

<table>

<tr><th>Parameter</th><th>Required</th><th>Description</th></tr>

<tr>
<td>myInstanceType</td>
<td>yes</td>
<td>
Instance type for your backups.
</td>
</tr>
<tr>
<td>mySubnetID</td>
<td>yes</td>
<td>
VPC subnet for your backup EC2 instance (ideally the same subnet as the production EFS mount point).
</td>
</tr>
<tr>
<td>mySrcSecGroupID</td>
<td>yes</td>
<td>
Security group that can connect to the Production EFS mount point.
</td>
</tr>
<tr>
<td>myBackupSecGroupID</td>
<td>yes</td>
<td>
Security group that can connect to the Backup EFS mount point.
</td>
</tr>
<tr>
<td>myInterval</td>
<td>yes</td>
<td>
Interval for backups (hourly, daily, weekly, monthly).
</td>
</tr>
<tr>
<td>myRetainedBackups</td>
<td>yes</td>
<td>
Number of backups to retain.
</td>
</tr>
<tr>
<td>myEfsID</td>
<td>yes</td>
<td>
Name of your backup directory.
</td>
</tr>
<tr>
<td>myEfsSource</td>
<td>yes</td>
<td>
Production EFS mount target IP address.
</td>
</tr>
<tr>
<td>myEfsBackup</td>
<td>yes</td>
<td>
Backup EFS mount target IP address.
</td>
</tr>
<tr>
<td>myShellCmd</td>
<td>yes</td>
<td>
Shell command to run.
</td>
</tr>

</table>

## Setup

To setup this backup solution you'll need to review the Amazon EFS online documentation on the subject, available here: http://docs.aws.amazon.com/efs/latest/ug/efs-backup.html. Consider the following when you're deciding whether to implement this solution:

<ul>
  <li>This backup solution involves a number of AWS resources. For this solution, you'll have to create:</li>
  <ul>
   <li>One production file system, and a backup file system that will contain a full copy of the production file system, plus any incremental changes to your data over the backup rotation period.</li>
   <li>Amazon EC2 instances, whose lifecycles are managed by AWS Data Pipeline, that perform restorations and scheduled backups.</li>
   <li>One regularly scheduled AWS Data Pipeline for backing up data.</li>
   <li>An ad hoc AWS Data Pipeline for restoring backups.</li>
  </ul>
  <li>When this solution is implemented, it will result in billing to your account for these services. For more information, see the pricing pages for Amazon EFS, Amazon EC2, and AWS Data Pipeline.</li>
  <li>This solution is not an offline backup. To ensure a fully consistent and complete back-up, pause any file writes to the file system or unmount the file system while the back-up occurs. It's recommended that you perform all backups during scheduled down time or off hours.</li>
</ul>

## To create a data pipeline for EFS backups

<ol>
  <li>Download the templates to a local directory on your computer, or save them to one of your S3 buckets.</li>
  <li>Navigate your internet browser to the AWS Data Pipeline console at https://console.aws.amazon.com/datapipeline/. Make sure that you're in the same region as your Amazon EFS file systems.</li>
  <li>Choose <b>Create new pipeline</b>.</li>
  <li>Add a <b>Name</b> and optional <b>Description</b>.</li>
  <li>For <b>Source</b>, select <b>Import a definition</b> and then choose <b>Load local file</b>.</li>
  <li>In the file explorer that opens, navigate to the template that you saved in Step 1 and choose Open.</li>
  <li>In <b>Parameters</b>, provide the details for both your backup and production EFS file systems.</li>
  <li>Configure the options in <b>Schedule</b> to define your Amazon EFS backup schedule. When a backup is seven days old, it is replaced with next oldest backup. It's recommended that you specify a runtime that occurs during your off-peak hours.</li>
  <li>When your pipeline is configured, choose Activate.</li>
</ol>

You’ve configured and activated your Amazon EFS backup data pipeline. For more information about AWS Data Pipelines, see the AWS Data Pipeline Developer Guide. At this stage, you can perform the backup now as a test, or you can wait until the backup is performed at the scheduled time.

More information, including how to access your backups and implement on-demand restorations, can be found in the Amazon EFS documentation, which can be found here: http://docs.aws.amazon.com/efs/latest/ug/efs-backup.html.

## Disclaimer

The samples in this repository are meant to help users get started with Data Pipeline. They may not
be sufficient for production environments. Users should carefully inspect samples before running
them.

*Use at your own risk.*

Copyright 2011-2015 Amazon.com, Inc. or its affiliates. All Rights Reserved. Licensed under the
[Amazon Software License](http://aws.amazon.com/asl/).
