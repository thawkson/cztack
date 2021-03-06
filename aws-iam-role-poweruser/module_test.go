package test

import (
	"testing"

	"github.com/chanzuckerberg/cztack/testutil"
	"github.com/gruntwork-io/terratest/modules/random"
)

func TestAWSIAMRolePowerUser(t *testing.T) {

	curAcct := testutil.AWSCurrentAccountId(t)

	terraformOptions := testutil.Options(
		testutil.IAMRegion,
		map[string]interface{}{
			"role_name":         random.UniqueId(),
			"source_account_id": curAcct,
		},
	)

	defer testutil.Cleanup(t, terraformOptions)

	testutil.Run(t, terraformOptions)
}
